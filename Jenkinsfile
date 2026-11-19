pipeline {
    agent any

    parameters {
        choice(name: 'ENV_GOAL', choices: ['staging', 'production'], description: 'AI Scaling Target')
    }

    environment {
        DOCKER_USER = 'abhichaman1'
        IMAGE_TAG   = "${env.BUILD_NUMBER}"
        ENV_GOAL    = "${params.ENV_GOAL}"
        GCP_PROJECT = 'project-dd40fd14-a91a-4c5a-bb9'
        GKE_CLUSTER = 'ideaboard-gke'
        GKE_ZONE    = 'asia-south1-a'
        AWS_REGION  = 'ap-south-1'
        EKS_CLUSTER = 'ideaboard-eks'
    }

    stages {
        stage('1. Setup Python & AI SDK') {
            steps {
                checkout scm
                sh '''
                    python3 -m venv .venv
                    .venv/bin/pip install -q -r ai-scripts/requirements.txt
                '''
            }
        }

        stage('2. Build & Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER_CRED', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER_CRED" --password-stdin

                        docker build -t $DOCKER_USER/ideaboard-backend:$IMAGE_TAG -t $DOCKER_USER/ideaboard-backend:latest ./backend
                        docker build -t $DOCKER_USER/ideaboard-frontend:$IMAGE_TAG -t $DOCKER_USER/ideaboard-frontend:latest ./frontend

                        docker push $DOCKER_USER/ideaboard-backend:$IMAGE_TAG
                        docker push $DOCKER_USER/ideaboard-backend:latest
                        docker push $DOCKER_USER/ideaboard-frontend:$IMAGE_TAG
                        docker push $DOCKER_USER/ideaboard-frontend:latest
                    '''
                }
            }
        }

        stage('3. Deploy & AI Ops on GCP (GKE)') {
            steps {
                withCredentials([string(credentialsId: 'gemini-api-key', variable: 'GEMINI_API_KEY')]) {
                    sh '''
                        # 1. Connect to GKE & Deploy
                        gcloud container clusters get-credentials $GKE_CLUSTER --zone $GKE_ZONE --project $GCP_PROJECT
                        kubectl apply -k k8s/overlays/gcp
                        kubectl rollout restart deployment/backend deployment/frontend
                        kubectl rollout status deployment/backend deployment/frontend --timeout=120s

                        # 2.  AI Dynamic Scaling
                        .venv/bin/python ai-scripts/generate_config.py
                        kubectl rollout status deployment/backend deployment/frontend --timeout=120s

                        # 3.  AI Health Check & Auto-Rollback
                        .venv/bin/python ai-scripts/health_guard.py
                    '''
                }
            }
        }

        stage('4. Deploy & AI Ops on AWS (EKS)') {
            steps {
                withCredentials([string(credentialsId: 'gemini-api-key', variable: 'GEMINI_API_KEY')]) {
                    sh '''
                        # 1. Connect to EKS & Deploy
                        aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER
                        kubectl apply -k k8s/overlays/aws
                        kubectl rollout restart deployment/backend deployment/frontend
                        kubectl rollout status deployment/backend deployment/frontend --timeout=120s

                        # 2. AI Dynamic Scaling
                        .venv/bin/python ai-scripts/generate_config.py
                        kubectl rollout status deployment/backend deployment/frontend --timeout=120s

                        # 3. AI Health Check & Auto-Rollback
                        .venv/bin/python ai-scripts/health_guard.py
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
