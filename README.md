# IdeaBoard — Multi-Cloud AIOps CI/CD Pipeline (AWS EKS + GCP GKE)

IdeaBoard is a containerized full-stack web application deployed simultaneously across **Google Kubernetes Engine (GKE)** and **Amazon Elastic Kubernetes Service (EKS)** using a Jenkins CI/CD pipeline enhanced with **Google Gemini AI** for dynamic replica scaling and automated post-deployment health checks with self-healing rollbacks.

---

## Architecture & Workflow

Instead of relying on static Kubernetes manifests and manual health checks, this pipeline puts an AI decision layer inside the release lifecycle:

```
Developer (git push)
       │
       ▼
Jenkins Server (AWS EC2 Ubuntu)
  ├── 1. Setup Python Virtualenv & Google GenAI SDK
  ├── 2. Build & Push Versioned Docker Images (:$BUILD_NUMBER & :latest)
  │         └── Docker Hub (abhichaman1/ideaboard-backend & frontend)
  │
  ├── 3. Deploy & AIOps on GCP (GKE - ideaboard-gke)
  │         ├── Apply Kustomize overlay & update exact image tag
  │         ├── Gemini AI (generate_config.py) -> Scales replicas based on ENV_GOAL
  │         └── Gemini AI (health_guard.py)    -> Audits pods/logs & auto-rollbacks on failure
  │
  └── 4. Deploy & AIOps on AWS (EKS - ideaboard-eks)
            ├── Apply Kustomize overlay & update exact image tag
            ├── Gemini AI (generate_config.py) -> Scales replicas based on ENV_GOAL
            └── Gemini AI (health_guard.py)    -> Audits pods/logs & auto-rollbacks on failure
```

### How the AIOps Layer Works
* **Dynamic Scaling (`ai-scripts/generate_config.py`):** Evaluates the target environment parameter (`staging` vs. `production`) using `gemini-3.5-flash-lite` and automatically scales `backend` and `frontend` deployments to balance cost and availability.
* **Self-Healing Health Guard (`ai-scripts/health_guard.py`):** Inspects live `kubectl get pods` states and recent container logs right after rollout. If CrashLoopBackOff, readiness failures, or application errors appear, it triggers an automatic `kubectl rollout undo` before bad code stays live.

---

## Project Structure

```text
ideaboard-multicloud-aiops/
├── backend/                  # FastAPI / Python backend service & Dockerfile
├── frontend/                 # React + Nginx frontend service & Dockerfile
├── k8s/
│   ├── base/                 # Core Kubernetes Deployments & Services
│   └── overlays/
│       ├── gcp/              # GKE-specific Kustomize configuration
│       └── aws/              # EKS-specific Kustomize configuration
├── ai-scripts/
│   ├── generate_config.py    # Gemini-powered dynamic replica scaler
│   ├── health_guard.py       # Gemini-powered health verifier & auto-rollback
│   └── requirements.txt      # Python dependencies (google-genai)
├── docker-compose.yml        # Local multi-container setup
└── Jenkinsfile               # Multi-cloud declarative CI/CD pipeline
```

---

## Running Locally with Docker Compose

If you want to run and test the frontend and backend locally before pushing changes:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Abhichaman/ideaboard-multicloud-aiops.git
   cd ideaboard-multicloud-aiops
   ```

2. **Start the application stack:**
   ```bash
   docker compose up --build -d
   ```

3. **Access the services:**
   * **Frontend UI:** `http://localhost:3000`
   * **Backend API:** `http://localhost:8000`

4. **Stop and clean up containers:**
   ```bash
   docker compose down
   ```

---

## Server & Jenkins CI/CD Setup (Ubuntu EC2)

To replicate this CI/CD control plane on a fresh Ubuntu server (recommended: `t2.large` or `2 vCPU / 4GB+ RAM`):

### 1. Required Ports & Firewall Rules
Make sure the following inbound ports are open in your cloud Security Group / Firewall (and allow traffic if using `kubectl port-forward` for testing):
* **`22`** — SSH access
* **`8080`** — Jenkins Web UI
* **`3000`** — Frontend service / port-forwarding
* **`8000`** — Backend API / port-forwarding

### 2. Install Core Tools (Java, Jenkins, Docker, Python)
```bash
sudo apt update && sudo apt install -y fontconfig openjdk-17-jre docker.io python3-venv python3-pip curl unzip

# Enable Docker and add jenkins user to docker group
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu

# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update && sudo apt install -y jenkins
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### 3. Install Cloud CLIs (`kubectl`, `aws-cli`, `gcloud`)
* **`kubectl`:**
  ```bash
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  ```
* **AWS CLI v2:**
  ```bash
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip && sudo ./aws/install
  ```
* **Google Cloud SDK (`gcloud` + GKE auth plugin):**
  ```bash
  sudo apt install -y apt-transport-https ca-certificates gnupg
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  sudo apt update && sudo apt install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
  ```

### 4. Authenticate Jenkins User with AWS & GCP
Switch to the `jenkins` user so the pipeline has direct kubeconfig and cloud permissions:
```bash
sudo su - jenkins
aws configure                                    # Enter AWS Access Key, Secret Key & region (ap-south-1)
gcloud auth login --no-launch-browser            # Authenticate GCP account
gcloud config set project <YOUR_GCP_PROJECT_ID>
exit
```

### 5. Configure Jenkins Credentials & Pipeline
1. Open Jenkins at `http://<SERVER_PUBLIC_IP>:8080`.
2. Go to **Manage Jenkins → Credentials → System → Global credentials** and add:
   * **`dockerhub-creds`** *(Username with password)* — Your Docker Hub username and access token.
   * **`gemini-api-key`** *(Secret text)* — Your Google AI Studio Gemini API key.
3. Create a new **Pipeline** job, point it to this Git repository (`main` branch, script path `Jenkinsfile`), and click **Build with Parameters** (`staging` or `production`).
