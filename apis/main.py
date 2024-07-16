from fastapi import FastAPI, HTTPException, UploadFile, File,Query
import json,os,whisper,time,voyageai,asyncio,markdown2,redis
from typing import List
from fastapi.responses import JSONResponse
from sentence_transformers import SentenceTransformer
from openai import OpenAI
from dotenv import load_dotenv
from groq import Groq
import numpy as np
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pathlib import Path
import google.generativeai as genai
from langchain.text_splitter import RecursiveCharacterTextSplitter

from functions.prepareEmbeddings import save_embeddings

from functions.getSuummary import getSummaryUsingGroq
from langchain_huggingface import HuggingFaceEmbeddings
from vertexai.generative_models import Content, GenerativeModel, Part
from fastui import prebuilt_html, FastUI, AnyComponent

from models import ChatLogRequest, ChatPart, ChatLogRequest, ChatResponse, EmbeddingRequest, EmbeddingResponse
from  redis_functions import get_chat_history, store_chat_history
from templates import gemini_system_prompt



import os
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
from pathlib import Path
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.vectorstores import Qdrant
from langchain_community.embeddings.fastembed import FastEmbedEmbeddings
from langchain_community.document_loaders import UnstructuredMarkdownLoader
from llama_parse import LlamaParse
import aiofiles
import nltk

nltk.download('averaged_perceptron_tagger')


from functions.similaritySearch import getSimilarity
app = FastAPI()
templates = Jinja2Templates(directory="templates")
app.mount("/static", StaticFiles(directory="static"), name="static")

# alibaba_model = SentenceTransformer('Alibaba-NLP/gte-large-en-v1.5', trust_remote_code=True)
embed_model = HuggingFaceEmbeddings(
    model_name="Alibaba-NLP/gte-Qwen2-1.5B-instruct",
)

origins = ["http://127.0.0.1:8000"]
load_dotenv()
vo = voyageai.Client()

chat_history = {
}
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
# model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
whisper_model = whisper.load_model("base")
r = redis.Redis(host='localhost', port=6379, db=0)

groq_client = Groq(
    # This is the default and can be omitted
    api_key=os.environ.get("GROQ_API_KEY"),
)


# Initialize OpenAI client


openai = OpenAI(
    api_key=  os.getenv("KRUTRIM_API_KEY"),
    base_url="https://cloud.olakrutrim.com/v1",
)


# @app.post("/embeddings/")
# async def get_embeddings(request: str):
#     print("this is the request ",request)
#     try:
#         # Generate embeddings   
#         embeddings = model.encode([request], show_progress_bar=True, prompt= '' )
#         return EmbeddingResponse(embeddings=embeddings.tolist())
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

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
    



@app.post("/transcribe/save")
async def transcribe_and_save(user: str, conversation_id:str ,audio_file: UploadFile = File(...), ):
    try:

        # Save the uploaded audio file
        file_path = f"uploads/{audio_file.filename}"
        with open(file_path, "wb") as audio:
            content = await audio_file.read()
            audio.write(content)

        # Call the transcription function with the file path
        transcription = whisper_model.transcribe(file_path)

        #save the trasncription in vector db

        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100, separators=[
            "\n\n",
            "\n",
            " ",
            ".",
            ",",
            "\u200b",  # Zero-width space
            "\uff0c",  # Fullwidth comma
            "\u3001",  # Ideographic comma
            "\uff0e",  # Fullwidth full stop
            "\u3002",  # Ideographic full stop
            "",
        ],)
        text = text_splitter.split_text(transcription["text"])
        

        save_embeddings(text, user, conversation_id, embed_model=embed_model)

        # Return the transcription as a JSON response
        return JSONResponse(status_code=200, content={"transcription": transcription["text"]})
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": str(e)})
    


@app.post("/transcribe/summarize/save")
async def transcribe_summarize_and_save(user: str, conversation_id:str ,audio_file: UploadFile = File(...), ):
    try:

        # Save the uploaded audio file
        file_path = f"uploads/{audio_file.filename}"
        with open(file_path, "wb") as audio:
            content = await audio_file.read()
            audio.write(content)

        # Call the transcription function with the file path
        transcription = whisper_model.transcribe(file_path)

        #save the trasncription in vector db

        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=10, separators=[
            "\n\n",
            "\n",
            " ",
            ".",
            ",",
            "\u200b",  # Zero-width space
            "\uff0c",  # Fullwidth comma
            "\u3001",  # Ideographic comma
            "\uff0e",  # Fullwidth full stop
            "\u3002",  # Ideographic full stop
            "",
        ],)
        texts = text_splitter.split_text(transcription["text"])

        summarized_text = getSummaryUsingGroq(texts)



            
        

        save_embeddings(summarized_text, user, conversation_id, embed_model=embed_model)

        # Return the transcription as a JSON response
        return JSONResponse(status_code=200, content={"transcription": transcription["text"]})
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": str(e)})
    



@app.post("/upload/pdf")
async def upload_pdf(user: str = Form(...), conversation_id: str = Form(...), pdf_file: UploadFile = File(...)):
    try:
        # Save the uploaded PDF file
        file_path = f"uploads/{pdf_file.filename}"
        async with aiofiles.open(file_path, 'wb') as out_file:
            content = await pdf_file.read()
            await out_file.write(content)

        # Initialize LlamaParse to parse the document
        instruction = """The provided document is to be processed into chunks."""
        parser = LlamaParse(api_key=os.getenv("LLAMA_PARSE_API_KEY"), result_type="markdown", parsing_instruction=instruction, max_timeout=5000)
        llama_parse_documents = await parser.aload_data(file_path)
        parsed_doc = llama_parse_documents[0]

        # Save parsed document to a temporary markdown file
        document_path = Path(f"uploads/{pdf_file.filename}.md")
        async with aiofiles.open(document_path, 'w') as f:
            await f.write(parsed_doc.text)
        print("reached to start")
        
        
        # Load the parsed document
        loader = UnstructuredMarkdownLoader(document_path)
        loaded_documents = loader.load()
        print("loaded documents ",loaded_documents)

        # Split the document into chunks
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=2048, chunk_overlap=128)
        docs = text_splitter.split_documents(loaded_documents)

        # Save embeddings to vector store
        texts = [doc.page_content for doc in docs]
        print("reached here " ,texts)
        await save_embeddings(texts, user, conversation_id, embed_model)

        return JSONResponse(status_code=200, content={"message": "PDF processed and embeddings saved successfully.", "document": parsed_doc.text})
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


# async def chat_stream(gemModel, prompt, buffer):
#     response = gemModel.send_message(prompt, stream = True)
#     content = response.text if hasattr(response, 'text') else response.content.decode()
#     # for i in range(0, len(content), 100):  # Adjust chunk size as needed
#     #     chunk = content[i:i+100]
#     #     yield chunk
#     #     print(chunk)
#     #     buffer.append(chunk)
#     #     # await asyncio.sleep(0.1)


#     for chunk in model.send_message(prompt, stream=True):
#         if token := chunk.choices[0].delta.content or "":
#         # Add the token to the output
#          output += token
#         # Send the message
#         m = FastUI(root=[c.Markdown(text=output)])
#         msg = f'data: {m.model_dump_json(by_alias=True, exclude_none=True)}\n\n'
#         yield msg 
#     # Append the message to the history
#     message = {"role": "user", "content": token}

#     app.message_history.append(message)
#     # Avoid the browser reconnecting
#     while True:
#         yield msg
#         await asyncio.sleep(10)


@app.get("/gemini/with-history")
async def query_with_history(user: str,query: str,id: str,  model_type: str = Query(default='text'), ):
    if not query:
        return ''
    
    similarDocs = getSimilarity(query= query, user= user, conversation_id= id, embed_model= embed_model)

    similarText = list_to_numbered_string(similarDocs)

    

    systemMessage = gemini_system_prompt + similarText 
    print("system message: ",systemMessage)

    generative_text_model = get_generative_model('gemini-1.5-pro-latest', system_instruction=systemMessage)
    models = {'text': generative_text_model}
    model = models.get(model_type)

    chat_history = get_chat_history(user, id, r)
    model_history = [{"role": entry["role"], "parts": [{"text": part["text"]} for part in entry["parts"]]} for entry in chat_history]

    chat = generative_text_model.start_chat(
        history=model_history,
       
    )
    if not model:
        raise HTTPException(status_code=400, detail="Invalid model type")
    prompt = query 
    return StreamingResponse(stream_my_res(chat, prompt, user ,id , r), media_type='text/event-stream')


@app.get("/gemini/with-history-no-stream")
async def query_with_history(user: str,query: str,id: str,  model_type: str = Query(default='text'), ):
    if not query:
        return ''
    
    similarDocs = getSimilarity(query= query, user= user, conversation_id= id, embed_model= embed_model)

    similarText = list_to_numbered_string(similarDocs)

    

    systemMessage = gemini_system_prompt + similarText 
    print("system message: ",systemMessage)

    generative_text_model = get_generative_model('gemini-1.5-pro-latest', system_instruction=systemMessage)
    models = {'text': generative_text_model}
    model = models.get(model_type)

    chat_history = get_chat_history(user, id, r)
    model_history = [{"role": entry["role"], "parts": [{"text": part["text"]} for part in entry["parts"]]} for entry in chat_history]

    chat = generative_text_model.start_chat(
        history=model_history,
       
    )
    if not model:
        raise HTTPException(status_code=400, detail="Invalid model type")
    prompt = query 
    chat_response = chat.send_message(prompt, 
                                      
        safety_settings= [
        {
            "category": "HARM_CATEGORY_DANGEROUS",
            "threshold": "BLOCK_NONE",
        },
        {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_NONE",
        },
        {
            "category": "HARM_CATEGORY_HATE_SPEECH",
            "threshold": "BLOCK_NONE",
        },
        {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_NONE",
        },
        {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_NONE",
        },])
    store_chat_history(username=user, conversation_id=id, text=prompt, role="user", r=r)
    store_chat_history(username=user, conversation_id=id, text=chat_response.text, role="model", r=r)
    return JSONResponse(status_code=200, content={"response": chat_response.text })
    

def stream_my_res(model,prompt, user , conversation_id, r):
    chat_parts = ""

    for chunk in model.send_message(
        prompt=prompt,
        stream=False,
        safety_settings= [
        {
            "category": "HARM_CATEGORY_DANGEROUS",
            "threshold": "BLOCK_NONE",
        },
        {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_NONE",
        },
        {
            "category": "HARM_CATEGORY_HATE_SPEECH",
            "threshold": "BLOCK_NONE",
        },
        {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_NONE",
        },
        {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_NONE",
        },]
                                    
        ):
        time.sleep(0.5)
        yield chunk.text
        chat_parts += chunk.text
        print(chunk.text)
    store_chat_history(username=user, conversation_id=conversation_id, text=prompt, role="user", r=r)
    store_chat_history(username=user, conversation_id=conversation_id, text=chat_parts, role="model", r=r)
        
    



@app.get('/voyage/embed')
async def voyage_embed(query: str):
    return vo.embed(query,model="voyage-large-2-instruct")


async def generate_content_stream(model, prompt):
    # Simulate streaming by breaking response into chunks
    response = model.generate_content(prompt)
    content = response.text if hasattr(response, 'text') else response.content.decode()
    for i in range(0, len(content), 100):  # Adjust chunk size as needed
        yield content[i:i+100]
        print(content[i:i+100])
        await asyncio.sleep(0.1)

# @app.get("/embeddings/alibaba")
# def get_alibaba_embeddings(request: str):
#     try:
#         # Generate embeddings   
#         alibaba_embeddings = alibaba_model.encode([request],)
#         return EmbeddingResponse(embeddings=alibaba_embeddings,)
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))
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


def list_to_numbered_string(items):
    """
    Converts a list of strings into a single numbered string.
    
    Args:
        items (list of str): The list of strings to convert.
    
    Returns:
        str: A single string with each item numbered and separated by newlines.
    """
    numbered_string = "\n".join(f"{i+1}. {item}" for i, item in enumerate(items))
    return numbered_string
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)

