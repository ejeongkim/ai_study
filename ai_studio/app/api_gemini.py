import os
from fastapi import FastAPI
from google import genai

app = FastAPI()

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/ask")
def ask(q: str = "Hello from kind"):
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return {"error": "GEMINI_API_KEY not set"}

    client = genai.Client(api_key=api_key)
    resp = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=q
    )
    return {"q": q, "answer": getattr(resp, "text", None)}