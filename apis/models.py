from fastapi import UploadFile
from pydantic import BaseModel

from typing import List


class AudioInput(BaseModel):
    audio_file: UploadFile
class EmbeddingRequest(BaseModel):
    sentences: str

class EmbeddingResponse(BaseModel):
    embeddings: List[List[float]]

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[ChatMessage]

class ChatResponse(BaseModel):
    response: str

# Pydantic models for request validation
class ChatPart(BaseModel):
    text: str
    role: str

class ChatLogRequest(BaseModel):
    username: str
    conversation_id: str
    chat_parts: ChatPart


class SearchRequest(BaseModel):
    query: str
    num_results: int = 10
    max_tokens: int = 4096
    model: str = "llama3-8b-8192"
    temperature: float = 0.0
    comprehension_grade: int = 8