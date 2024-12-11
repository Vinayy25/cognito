
import os
from models import SearchRequest
from Groqqle_web_tool import Groqqle_web_tool
from fastapi import HTTPException



async def search_web(request: SearchRequest):
    try:
        # Initialize the Groqqle web tool with the provided API key and parameters
        groqqle_tool = Groqqle_web_tool(
            api_key=os.getenv('GROQ_API_KEY'),
            num_results=request.num_results,
            max_tokens=request.max_tokens,
            model=request.model,
            temperature=request.temperature,
            comprehension_grade=request.comprehension_grade
        )

        # Perform the web search
        results = groqqle_tool.run(request.query)
        return results

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))