import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const resp = await ai.models.generateContent({
  model: "gemini-2.0-flash",
  contents: "WSL에서 Gemini API 호출 테스트. 한 문장으로 인사해줘."
});

console.log(resp.text);