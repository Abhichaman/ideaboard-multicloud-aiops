import os
import time
from datetime import datetime
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor

app = FastAPI(title="Idea Board API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://postgres:postgres@db:5432/ideaboard"
)

def get_db_connection():
    for _ in range(5):
        try:
            return psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)
        except Exception:
            time.sleep(2)
    raise Exception("Could not connect to database")

@app.on_event("startup")
def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS ideas (
            id SERIAL PRIMARY KEY,
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    """)
    conn.commit()
    cur.close()
    conn.close()

class IdeaCreate(BaseModel):
    content: str

@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}

@app.get("/api/ideas")
def get_ideas():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, content, created_at FROM ideas ORDER BY created_at DESC;")
    ideas = cur.fetchall()
    cur.close()
    conn.close()
    return ideas

@app.post("/api/ideas")
def create_idea(idea: IdeaCreate):
    if not idea.content.strip():
        raise HTTPException(status_code=400, detail="Content cannot be empty")
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO ideas (content) VALUES (%s) RETURNING id, content, created_at;",
        (idea.content.strip(),),
    )
    new_idea = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return new_idea