from config import Settings
from tavily import TavilyClient
import trafilatura
import time
settings = Settings()
tavily_client = TavilyClient(api_key=settings.TAVILY_API_KEY)


class SearchService:
    def web_search(self, query: str):
        try:
            response = tavily_client.search(
                query,
                search_depth="basic",
                max_results=5,
                # include_content=True
            )

            results = []

            for result in response.get("results", []):
                results.append({
                    "title": result.get("title", ""),
                    "url": result.get("url", ""),
                    "content": result.get("content", "")
                })

            return results

        except Exception as e:
            print("Search Error:", e)
            return []
        