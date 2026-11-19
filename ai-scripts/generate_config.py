import os
import json
import subprocess
from google import genai

# 1. Gemini Client setup
client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
env_goal = os.getenv("ENV_GOAL", "staging")

# 2. Simple Prompt
prompt = f"""
For a '{env_goal}' environment, suggest Kubernetes replica counts.
Reply ONLY in raw JSON format like: {{"backend": 1, "frontend": 1, "reason": "short reason"}}
"""

# 3. Call AI & Parse JSON
response = client.models.generate_content(model="gemini-3.5-flash-lite", contents=prompt)
clean_json = response.text.strip().removeprefix("```json").removesuffix("```").strip()
config = json.loads(clean_json)

print("AI Decision:", config)

# 4. Scale Kubernetes Deployments
subprocess.run(["kubectl", "scale", "deployment/backend", f"--replicas={config['backend']}"])
subprocess.run(["kubectl", "scale", "deployment/frontend", f"--replicas={config['frontend']}"])
