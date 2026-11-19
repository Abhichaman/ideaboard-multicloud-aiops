import os
import json
import time
import subprocess
from google import genai

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
time.sleep(10)  # Pods start hone ka wait

# 1. Cluster status aur logs collect 
pods = subprocess.getoutput("kubectl get pods")
logs = subprocess.getoutput("kubectl logs -l app=backend --tail=20")

# 2. AI health check 
prompt = f"""
Check if this Kubernetes deployment is healthy based on pods and logs.
Pods:\n{pods}\nLogs:\n{logs}
Reply ONLY in raw JSON format like: {{"healthy": true, "summary": "short reason"}}
"""

response = client.models.generate_content(model="gemini-3.5-flash-lite", contents=prompt)
clean_json = response.text.strip().removeprefix("```json").removesuffix("```").strip()
result = json.loads(clean_json)

print("AI Health Report:", result)

# 3. If unhealthy then Auto-Rollback
if not result["healthy"]:
    print("Error detected! Rolling back deployment...")
    subprocess.run(["kubectl", "rollout", "undo", "deployment/backend"])
    subprocess.run(["kubectl", "rollout", "undo", "deployment/frontend"])
    exit(1)
