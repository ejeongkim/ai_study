import os
from google import genai

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

resp = client.models.generate_content(
    model="gemini-2.0-flash",
    contents="WSL에서 Gemini API 호출 테스트. 한 문장으로 인사해줘."
)
print(resp.text)