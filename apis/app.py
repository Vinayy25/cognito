from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
from typing import List, Dict, Any
from Groqqle_web_tool import Groqqle_web_tool
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

class SearchRequest(BaseModel):
    query: str
    num_results: int = 10
    max_tokens: int = 4096
    model: str = "llama3-8b-8192"
    temperature: float = 0.0
    comprehension_grade: int = 8

@app.post("/search")
async def search(request: SearchRequest):
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
        return {"results": results}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
