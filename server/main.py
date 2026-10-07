import asyncio
import time
from fastapi import FastAPI, WebSocket

from pydantic_models.chat_body import ChatBody
from services.llm_service import LLMService
from services.sort_source_service import SortSourceService
from services.search_service import SearchService

app = FastAPI()

search_service = SearchService()
sort_source_service = SortSourceService()
llm_service = LLMService()


@app.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    await websocket.accept()
    
    try:
        data = await websocket.receive_json()
        query = data.get("query")

        # Search
        search_results = await asyncio.to_thread(search_service.web_search, query)
        sorted_results = await asyncio.to_thread(sort_source_service.sort_sources, query, search_results)

        await websocket.send_json({
            "type": "search_result",
            "data": sorted_results
        })

        # Stream LLM + đo thời gian
        start = time.time()
        print("Bắt đầu gọi Gemini...")
        first_chunk = True

        for chunk in llm_service.generate_response(query, sorted_results):
            if first_chunk:
                print(f"Nhận chunk đầu tiên sau: {time.time() - start:.2f}s")
                first_chunk = False

            await websocket.send_json({
                "type": "content",
                "data": chunk
            })

        print("Stream xong")

    except Exception as e:
        print(f"Error: {e}")
        await websocket.send_json({"type": "error", "data": str(e)})
    finally:
        await websocket.close()


@app.post("/chat")
def chat_endpoint(body: ChatBody):
    search_results = search_service.web_search(body.query)
    sorted_results = sort_source_service.sort_sources(body.query, search_results)

    full_response = "".join(llm_service.generate_response(body.query, sorted_results))
    
    return {"response": full_response}