# API Documentation

This document provides details on all available API endpoints, their functionality, and usage.

## 1. Chat Endpoints

### POST `/chat`
Generate a chat completion using the Krutrim model.

#### Request Parameters
- `message` (str): User's input message.
- `systemMessage` (str): System prompt for the model.

#### Response
- **200 OK**: JSON containing the model's response.
- **500 Internal Server Error**: Error details if an exception occurs.

---

### GET `/`
Test endpoint.

#### Response
- **200 OK**: `{"message": "Why are you gay"}`

---

## 2. Audio Transcription Endpoints

### POST `/transcribe/`
Transcribe audio to text.

#### Request Parameters
- `audio_file` (UploadFile): The uploaded audio file.

#### Response
- **200 OK**: JSON containing the transcription.
- **500 Internal Server Error**: Error details if an exception occurs.

---

### POST `/transcribe/save`
Transcribe audio and save embeddings to a vector database.

#### Request Parameters
- `user` (str): User ID.
- `conversation_id` (str): Conversation ID.
- `audio_file` (UploadFile): The uploaded audio file.

#### Response
- **200 OK**: JSON containing the transcription.
- **500 Internal Server Error**: Error details if an exception occurs.

---

### POST `/transcribe/summarize/save/`
Transcribe, summarize, and save embeddings to a vector database.

#### Request Parameters
- `user` (str): User ID.
- `conversation_id` (str): Conversation ID.
- `audio_file` (UploadFile): The uploaded audio file.

#### Response
- **200 OK**: JSON containing the transcription.
- **500 Internal Server Error**: Error details if an exception occurs.

---

## 3. PDF Upload Endpoint

### POST `/upload/pdf`
Upload and process a PDF file for embeddings.

#### Request Parameters
- `user` (str): User ID (Form field).
- `conversation_id` (str): Conversation ID (Form field).
- `pdf_file` (UploadFile): The uploaded PDF file.

#### Response
- **200 OK**: JSON indicating successful processing.
- **500 Internal Server Error**: Error details if an exception occurs.

---

## 4. GROQ Endpoints

### GET `/groq/chat-json/`
Chat using the GROQ model and return a JSON response.

#### Request Parameters
- `message` (str): User's input message.
- `systemMessage` (str): System prompt for the model.

#### Response
- **200 OK**: JSON containing the model's response.
- **500 Internal Server Error**: Error details if an exception occurs.

---

### GET `/groq/chat/`
Chat using the GROQ model.

#### Request Parameters
- `message` (str): User's input message.
- `systemMessage` (str): Default system prompt.

#### Response
- **200 OK**: JSON containing the model's response.
- **500 Internal Server Error**: Error details if an exception occurs.

---

## 5. Gemini Endpoints

### GET `/gemini`
Generate a response using the Gemini model.

#### Request Parameters
- `query` (str): User's query.
- `model_type` (str): Model type (default: "text").
- `systemMessage` (str): System message.

#### Response
- **200 OK**: Text response streamed back.
- **400 Bad Request**: Invalid model type.

---

### GET `/gemini/with-history`
Query the Gemini model with history.

#### Request Parameters
- `user` (str): User ID.
- `query` (str): User's query.
- `id` (str): Conversation ID.
- `model_type` (str): Model type (default: "text").

#### Response
- **200 OK**: Text response streamed back.
- **400 Bad Request**: Invalid model type.

---

### GET `/gemini/with-history-no-stream`
Query the Gemini model with history (no streaming).

#### Request Parameters
- `user` (str): User ID.
- `query` (str): User's query.
- `id` (str): Conversation ID.
- `model_type` (str): Model type (default: "text").

#### Response
- **200 OK**: JSON containing the model's response.
- **400 Bad Request**: Invalid model type.

---

## 6. Audio Chat Endpoints

### GET `/audio-chat`
Generate audio responses using history.

#### Request Parameters
- `user` (str): User ID.
- `query` (str): User's query.
- `id` (str): Conversation ID.
- `model_type` (str): Model type (default: "text").

#### Response
- **200 OK**: Returns an audio file (MP3 format).
- **500 Internal Server Error**: Error details if an exception occurs.

---

### POST `/audio-chat-stream`
Stream audio responses using history.

#### Request Parameters
- `user` (str): User ID.
- `id` (str): Conversation ID.
- `model_type` (str): Model type (default: "text").
- `perform_rag` (str): Perform RAG (default: "false").

body:
- `audio_file` (UploadFile): Input audio file.

#### Response
- **200 OK**: Streams the audio response.
- **500 Internal Server Error**: Error details if an exception occurs.

---

## 7. Text Streaming Endpoints

### GET `/chat-stream`
Stream text responses.

#### Request Parameters
- `user` (str): User ID.
- `query` (str): User's query.
- `id` (str): Conversation ID.
- `perform_rag` (str): Perform RAG (default: "false").
- `model_type` (str): Model type (default: "text").

#### Response
- **200 OK**: Streams the response as text.
- **500 Internal Server Error**: Error details if an exception occurs.

---

## 8. Image Analysis Endpoint

### POST `/analyze-image`
Analyze an uploaded image based on a prompt.

#### Request Parameters
- `file` (UploadFile): The uploaded image file.
- `prompt` (str): Instruction for analysis.

#### Response
- **200 OK**: JSON containing the analysis result.
- **500 Internal Server Error**: Error details if an exception occurs.

---

### POST `/groq/transcribe/`
Transcribe audio using the GROQ model.

#### Request Parameters
- `audio_file` (UploadFile): The uploaded audio file.

#### Response
- **200 OK**: JSON containing the transcription.
- **500 Internal Server Error**: Error details if an exception occurs.

---

## Notes
- Replace placeholder values in the endpoints with actual data.
- Ensure proper file handling and cleanup when testing locally.
