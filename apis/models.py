from fastapi import UploadFile, File, Query
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