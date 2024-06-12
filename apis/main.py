from fastapi import FastAPI, HTTPException, UploadFile, File,Query
from pydantic import BaseModel
from typing import List
from fastapi.responses import JSONResponse
from sentence_transformers import SentenceTransformer
from openai import OpenAI
import whisper 
from dotenv import load_dotenv
import os
from groq import Groq
import numpy as np
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pathlib import Path
import google.generativeai as genai
import markdown2
import asyncio




app = FastAPI()
templates = Jinja2Templates(directory="templates")
app.mount("/static", StaticFiles(directory="static"), name="static")

origins = ["http://127.0.0.1:8000"]
load_dotenv()

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
def get_generative_model(model_name, system_instruction = ""):
    genai.configure(api_key=os.environ.get("GEMINI_API_KEY"))
    return genai.GenerativeModel(model_name, system_instruction = system_instruction,)


# generative_image_model = get_generative_model('gemini-pro-vision')
# Initialize the model
model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
whisper_model = whisper.load_model("base")

groq_client = Groq(
    # This is the default and can be omitted
    api_key=os.environ.get("GROQ_API_KEY"),
)


# Initialize OpenAI client


openai = OpenAI(
    api_key=  os.getenv("KRUTRIM_API_KEY"),
    base_url="https://cloud.olakrutrim.com/v1",
)
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

@app.post("/embeddings/")
async def get_embeddings(request: str):
    try:
        # Generate embeddings   
        embeddings = model.encode([request], show_progress_bar=True, prompt= '' )
        return EmbeddingResponse(embeddings=embeddings.tolist())
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/chat", response_model=ChatResponse)
async def krutrim_chat(message: str, systemMessage : str ):
    try:
        # Generate chat completion using Krutrim m  odel
        chat_completion = openai.chat.completions.create(
       
            
    model="Meta-Llama-3-8B-Instruct",
    messages=[
        {"role": "system", "content": systemMessage},
        {"role": "user", "content": message} 
    ]
)     
    
        return ChatResponse(response=chat_completion.choices[0].message.content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 
    


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.post("/transcribe/")
async def transcribe_audio_endpoint(audio_file: UploadFile = File(...)):
    try:

        # Save the uploaded audio file
        file_path = f"uploads/{audio_file.filename}"
        with open(file_path, "wb") as audio:
            content = await audio_file.read()
            audio.write(content)

        # Call the transcription function with the file path
        transcription = whisper_model.transcribe(file_path)
   
        # Return the transcription as a JSON response
        return {"transcription": transcription["text"]}
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": str(e)})
    
@app.post("/groq/chat", response_model=ChatResponse)
def groq_chat(message: str, systemMessage : str):
    try:
        # Generate chat completion using GROQ model
       groq_chat_completion = groq_client.chat.completions.create(
         messages=[
        {
            
            "role": "system",
            "content":systemMessage,
        },
        {
            "role": "user",
            "content": message,
        }
             ],
             model="llama3-70b-8192",
               )
       
       return ChatResponse(response=groq_chat_completion.choices[0].message.content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# @app.post('/prompt/chat')
# def prompt_chat():
#     return chat() 

@app.get("/gemini")
async def query(query: str, model_type: str = Query(default='text'), systemMessage: str = Query(default='')):
    if not query:
        return ''
    
    generative_text_model = get_generative_model('gemini-1.5-pro-latest',system_instruction=systemMessage)
    models = {'text': generative_text_model}
    model = models.get(model_type)

    if not model:
        raise HTTPException(status_code=400, detail="Invalid model type")
    prompt = query
    response = model.generate_content(
        prompt,
        stream = True
    )

    return StreamingResponse(generate_content_stream(model, prompt), media_type='text/plain')
    response_text = response.text if hasattr(response, 'text') else response.content.decode()
   
    return StreamingResponse( response_text, media_type='text/plain')





async def generate_content_stream(model, prompt):
    # Simulate streaming by breaking response into chunks
    response = model.generate_content(prompt)
    content = response.text if hasattr(response, 'text') else response.content.decode()
    for i in range(0, len(content), 100):  # Adjust chunk size as needed
        yield content[i:i+100]
        print(content[i:i+100])
        await asyncio.sleep(0.1)  



def to_html(markdown_format):
    return (
        markdown2.markdown(markdown_format)
        .replace("\\", "")
        .replace("<h1>", "<h7>")
        .replace("</h1>", "</h7>")
        .replace("\\\\", "")
        .replace("```", "")
        .replace("python", "")
        .replace("\n","<br>")
        .replace('"',"")
        .replace("#","<b>")
    )

def removeEmpty(paragraph):
    lines = paragraph.split('\n')
    non_empty_lines = [line for line in lines if line.strip() != '']
    cleaned_paragraph = '\n'.join(non_empty_lines)
    return cleaned_paragraph

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)

