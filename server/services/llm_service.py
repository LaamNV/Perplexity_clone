from google import genai
from google.genai import types
from config import Settings

settings = Settings()


class LLMService:
    def __init__(self):
        self.client = genai.Client(
            api_key=settings.GEMINI_API_KEY
        )

    def generate_response(
        self,
        query: str,
        search_results: list[dict]
    ):
        context_text = "\n\n".join([
            f"Source {i+1} ({result['url']}):\n{result['content'][:4000]}"
            for i, result in enumerate(search_results[:5])
            if result.get("content")
        ])

        prompt = f"""
Sử dụng các nguồn web dưới đây để trả lời câu hỏi.

Nguồn:
{context_text}

Câu hỏi:
{query}

Yêu cầu:
- Trả lời chính xác dựa trên các nguồn đã cho.
- Trích dẫn nguồn liên quan.
- Trả lời hoàn toàn bằng tiếng Việt.
- Ngắn gọn, rõ ràng, không giải thích thừa.
"""

        response = self.client.models.generate_content_stream(
    model="gemini-2.5-flash",
    contents=prompt,
    config=types.GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=4000,
    ),
)

        for chunk in response:
            if chunk.text:
                yield chunk.text