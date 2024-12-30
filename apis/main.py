from fastapi import FastAPI, HTTPException, UploadFile, File,Query, Request, WebSocket, WebSocketDisconnect
import json,os,time,voyageai,asyncio,markdown2,redis
from typing import List
from fastapi.responses import FileResponse, JSONResponse
from openai import OpenAI
from dotenv import load_dotenv
from groq import Groq
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pathlib import Path
from Groqqle_web_tool import Groqqle_web_tool
from functions.genModel import get_generative_model, get_embed_model
from langchain.text_splitter import RecursiveCharacterTextSplitter
from functions.prepareEmbeddings import save_embeddings
from functions.getSummary import getSummaryUsingGroq
from tts_deepgram import get_audio_deepgram
from functions.groqChat import groqResponse
from functions.groqAudio import translate_audio
from helpers.formatting import list_to_numbered_string
from tts_deepgram import get_audio_deepgram
from functions.groqVision import analyze_image
from fastapi.responses import HTMLResponse
from functions.search import search_web

import markdown
from models import  ChatResponse, SearchRequest
from  redis_functions import get_chat_history, store_chat_history
from templates import gemini_system_prompt, system_prompt_without_rag

from PIL import Image
import os
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
from pathlib import Path
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import UnstructuredMarkdownLoader
from llama_parse import LlamaParse
from functions.groqChat import stream_groq_response
import aiofiles
import nltk
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from dotenv import load_dotenv

nltk.download('averaged_perceptron_tagger')
load_dotenv()

from functions.similaritySearch import getSimilarity
app = FastAPI()
templates = Jinja2Templates(directory="templates")


from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware
from starlette.middleware.gzip import GZipMiddleware

app.add_middleware(GZipMiddleware)

# Set maximum file size
MAX_UPLOAD_SIZE = 20 * 1024 * 1024  # 20 MB
app.add_middleware(TrustedHostMiddleware, allowed_hosts=["*"])

# embed_model = HuggingFaceEmbeddings(
#     model_name="Alibaba-NLP/gte-Qwen2-1.5B-instruct",
# )


# Set up the Groq client
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))
groq_model_name = os.environ.get("GROQ_MODEL")



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




# generative_image_model = get_generative_model('gemini-pro-vision')
# Initialize the model
# model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
# whisper_model = whisper.load_model("base")

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
    return {"message": "Why are you gay"}


@app.post("/transcribe/")
async def transcribe_audio_endpoint(audio_file: UploadFile = File(...)):
    try:

        # Save the uploaded audio file
        file_path = f"uploads/{audio_file.filename}"
        with open(file_path, "wb") as audio:
            content = await audio_file.read()
            audio.write(content)

        # Call the transcription function with the file path
        transcription = translate_audio(file_path)
        
   
        # Return the transcription as a JSON response
        return {"transcription": transcription}
    except Exception as e:
        print("error in transcribe ",e)
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
        transcription = translate_audio(file_path)

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
        text = text_splitter.split_text(transcription)
        print ("reached here")
        
        print("text ",text)
        embed_model = get_embed_model()
        save_embeddings(text, user, conversation_id, embed_model=embed_model)

        # Return the transcription as a JSON response
        return JSONResponse(status_code=200, content={"transcription": transcription})
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": str(e)})
    


@app.post("/transcribe/summarize/save/")
async def transcribe_summarize_and_save(user: str, conversation_id:str ,audio_file: UploadFile = File(...), ):
    try:

        # Save the uploaded audio file
        file_path = f"uploads/{audio_file.filename}"
        with open(file_path, "wb") as audio:
            content = await audio_file.read()
            audio.write(content)

        # Call the transcription function with the file path
        transcription = translate_audio(file_path)
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
        texts = text_splitter.split_text(transcription)
        print("texts ",texts)

        summarized_text = getSummaryUsingGroq(texts)
        embed_model = get_embed_model()
        save_embeddings(summarized_text, user, conversation_id, embed_model=embed_model)

        # Return the transcription as a JSON response
        return JSONResponse(status_code=200, content={"transcription": transcription})
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
        embed_model = get_embed_model()
        await save_embeddings(texts, user, conversation_id, embed_model)

        return JSONResponse(status_code=200, content={"message": "PDF processed and embeddings saved successfully.", "document": parsed_doc.text})
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": str(e)})


@app.get("/groq/chat-json/", )
def groq_chat(message: str, systemMessage : str):
        try:
                # Generate chat completion using GROQ model
            print("got a groq request ")
            groq_chat_completion = groq_client.chat.completions.create(
                response_format={"type": "json_object"},
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
                    model="llama-3.2-3b-preview",
                    )
            return JSONResponse(status_code=200, content={ "response": groq_chat_completion.choices[0].message.content,})
            
        except Exception as e:
                raise HTTPException(status_code=500, detail=str(e))
            



@app.get("/groq/chat/", )
def groq_chat(message: str, systemMessage: str = "you are a very helpful ai assistant that answers in short"):
        try:
                # Generate chat completion using GROQ model
            print("got a groq request ")
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
                    model="llama-3.2-90b-vision-preview",
                    )
            return JSONResponse(status_code=200, content={ "response": groq_chat_completion.choices[0].message.content,})
            
        except Exception as e:
                raise HTTPException(status_code=500, detail=str(e))
            
@app.websocket("/groq/chat-stream/ws")
async def groq_chat_websocket(
    websocket: WebSocket, 
    user: str, 
    query: str, 
    id: str, 
    model_type: str, 
    perform_rag: str, 
    perform_web_search: str
):
    await websocket.accept()
    try:
        # Initial configuration
        print("Got a GROQ WebSocket request")
        if perform_rag == "true" or perform_web_search == "true":
            word_length = 1000
        else:
            word_length = 100

        embed_model = get_embed_model()

        if perform_web_search == "true":
            print("Performing web search")
            res = await search_web(
                SearchRequest(
                    query=query,
                    num_results=10,
                    max_tokens=4096,
                    model="llama3-8b-8192",
                    temperature=0.5,
                    comprehension_grade=8,
                )
            )
            print("res", res)

            # Process the web search results
            res_string = "\n".join(
                f"Title: {entry.get('title', 'N/A')}\n"
                f"Description: {entry.get('description', 'N/A')}\n"
                f"URL: {entry.get('url', 'N/A')}\n"
                for entry in res
            )

            query = f"{query} \nHere are the web search results for you to refer to\n{res_string}"
        if perform_rag == "true":
            similarDocs = getSimilarity(query=query, user=user, conversation_id=id, embed_model=embed_model)
            similarText = list_to_numbered_string(similarDocs)
            systemMessage = gemini_system_prompt + similarText   + " Make sure to answer in less than " + str(word_length) + " words"
        else:
            systemMessage = gemini_system_prompt + " Make sure to answer in less than " + str(word_length) + " words"

        # Initialize chat history with system message for Groq  
        chat_history = [{"role": "system", "content": systemMessage}]
        
        # Load previous chat history from Redis and format for Groq
        previous_chats = get_chat_history(user, id, r)
        for entry in previous_chats:
            role = entry.get("role")
            if role not in {"user", "assistant"}:
                print(f"Invalid role '{role}' in chat history. Skipping this entry.")
                continue
            chat_history.append({"role": role, "content": entry["parts"][0]["text"]})
        
        # Add the current user query to the chat history
        chat_history.append({"role": "user", "content": query})

        # Make the API call and stream the response
        response = client.chat.completions.create(
            model= groq_model_name,
            messages=chat_history,
            stream=True,
            
        )

        assistant_response=""

        for chunk in response:
            text = chunk.choices[0].delta.content
            if chunk.choices[0].finish_reason:
                store_chat_history(username=user, conversation_id=id, text=query, role="user", r=r)
                store_chat_history(username=user, conversation_id=id, text=assistant_response, role="assistant", r=r)
                break
            else:
                assistant_response += text
                await websocket.send_json({"type": "content", "data": text})
    except WebSocketDisconnect:
        print("WebSocket disconnected")
    except Exception as e:
        await websocket.send_text(f"Error: {str(e)}")
        print("Exception occurred:", str(e))
    finally:
        await websocket.close()



@app.get("/groq/chat-stream/")
async def groq_chat(user: str, query: str, id: str, model_type: str, perform_rag: str, perform_web_search: str):
    try:
        # Generate chat completion using GROQ model
        print("got a groq request")
        if perform_rag == "true" or perform_web_search == "true":
            word_length = 1000
        else:
            word_length = 100
        embed_model = get_embed_model()
        
        if perform_web_search == "true":
            print("performing web search")
            res = await search_web(
                SearchRequest(
                    query=query,
                    num_results=10,
                    max_tokens=4096,
                    model='llama3-8b-8192',
                    temperature=0.5,
                    comprehension_grade=8
                )
            )
            print("res ", res)

            # Process the web search results
            res_string = "\n".join(
                f"Title: {entry.get('title', 'N/A')}\n"
                f"Description: {entry.get('description', 'N/A')}\n"
                f"URL: {entry.get('url', 'N/A')}\n"
                for entry in res
            )


            query  = f"{query} \nHere are the web search results for you to refer to\n{res_string}"
          
        return StreamingResponse(
            #giving perform rag as false because we are already doing it before
            stream_groq_response(user, id, query,word_length,  r, embed_model, perform_rag=perform_rag),
            media_type='text/plain'
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



@app.get("/gemini")
async def query(query: str, model_type: str = Query(default='text'), systemMessage: str = Query(default='')):
    if not query:
        return ''
    generative_text_model = get_generative_model('gemini-1.5-flash',system_instruction=systemMessage)
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


@app.get("/gemini/with-history")
async def query_with_history(user: str,query: str,id: str,  model_type: str = Query(default='text'), ):
    if not query:
        return ''
    embed_model = get_embed_model()
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

@app.get("/audio-chat")
async def query_with_history_and_audio(user: str,query: str,id: str,  model_type: str = Query(default='text')):
    if not query:
        return ''
    embed_model = get_embed_model()
    chat_response = groqResponse(user, id, query, r, embed_model)
    time_stamp = time.time()
    filename = f"audios/{user}_{id}_{time_stamp}.mp3"
    #get_audio_deepgram returns the filename of the audio 
    # get_audio_deepgram(chat_response.text, filename=filename) 
    get_audio_deepgram(chat_response, filename=filename)
    

    return FileResponse(
        path=filename,
        media_type="audio/mp3",
        filename=filename,
    )



@app.post("/audio-chat-stream", response_class=StreamingResponse)
async def query_with_history_and_audio_stream(user: str, id: str,  audio_file: UploadFile = File(...), model_type: str = Query(default='text'),perform_rag: str = Query(default='false'),):
    embed_model = get_embed_model()
    buffer = []
    filename = f"uploads/{user}_{id}_audio.wav"
    
    temp_file_path = f"uploads/{audio_file.filename}"
    with open(temp_file_path, "wb") as temp_file:
        temp_file.write(await audio_file.read())



    query = translate_audio(temp_file_path)
    
    if perform_rag == "true":
        word_length = 500
    else:
        word_length = 100

    if not query:
        return ''
    async def iterfile():
        async for chunk in stream_groq_response(user, id, query, word_length, r , embed_model, perform_rag=perform_rag):
            buffer.append(chunk)
            # in the if condition make sure to not break sentances that have a decimal number in them as . is a valid character in a decimal number not only .0
            if chunk.endswith('.') and not chunk.endswith('.0'):
                sentence = ''.join(buffer)
                
                print("sentence ",sentence)
                buffer.clear()
                audio_files = get_audio_deepgram(sentence, filename=filename)
                
                if audio_files is not None:
                    async with aiofiles.open(filename, mode="rb") as file_like:
                        while chunk := await file_like.read(1024):
                                yield chunk

        # Handle any remaining text in the buffer as the last sentence
        print("reached pass the function")
        if buffer:
            sentence = ''.join(buffer)
            audio_files = get_audio_deepgram(sentence, filename=filename)
            
            if audio_files is not None:
                async with aiofiles.open(filename, mode="rb") as file_like:
                    while chunk := await file_like.read(1024):
                        yield chunk

    return StreamingResponse(iterfile(), media_type="audio/wav")
   


@app.post("/analyze-image")
async def analyze_image_endpoint(user: str, conversation_id: str, file: UploadFile = File(...), prompt: str = Query(default='Analyze the image and describe it in detail in strictly less than 100 words')):
    try:
        # Save the uploaded file to a temporary location
        temp_file_path = f"uploads/{file.filename}"
        with open(temp_file_path, "wb") as temp_file:
            temp_file.write(await file.read())
        #if the image is larger than 4mb compress it
        if os.path.getsize(temp_file_path) > 4 * 1024 * 1024:
            compress_image(temp_file_path, temp_file_path, max_size_mb=4)
        # Call the analyze_image function
        response_content = analyze_image(temp_file_path, prompt)


        # Remove the temporary file
        os.remove(temp_file_path)

        return {"response": response_content}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/groq/transcribe/")
async def transcribe_audio(audio_file: UploadFile = File(...)):
    try:
        # Save the uploaded file to a temporary location
        temp_file_path = f"uploads/{audio_file.filename}"
        with open(temp_file_path, "wb") as temp_file:
            temp_file.write(await audio_file.read())

        # Call the translate_audio function
        transcription_text = translate_audio(temp_file_path)

        return JSONResponse(status_code=200, content={"transcription": transcription_text})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/gemini/with-history-no-stream")
async def query_with_history(user: str,query: str,id: str,  model_type: str = Query(default='text'), ):
    if not query:
        return ''
    embed_model = get_embed_model()
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
        
@app.get("/chat-summary-title/")
async def get_chat_history_as_text(username: str, conversation_id: str):
    try:
        # Retrieve chat history from Redis
        chat_history = get_chat_history(username, conversation_id, r)
        # Format chat history as a single text with different lines for each chat
        
        formatted_chat_history = ""
        for entry in chat_history:
            role = entry.get("role", "unknown").capitalize()
            for part in entry.get("parts", []):
                text = part.get("text", "")
                formatted_chat_history += f"{role}: {text}\n"
        system_message_for_groq = "Given the following conversation data , generate a small summary of less than 10 words and a title for showing the chat preview ALSO in JSON format with keys summary and title, do not include any other text or body , respond only with json of summary and title"
        
        groq_chat_completion = groq_client.chat.completions.create(
                messages=[
                {
                    "role": "system",
                    "content":system_message_for_groq,
                },
                {
                    "role": "user",
                    "content": formatted_chat_history,
                }
                    ],
                    model="llama3-70b-8192",
                    )
        chat_summary_and_title= groq_chat_completion.choices[0].message.content
       
        if is_valid_json(chat_summary_and_title):
            print("is valid")
            chat_summary_and_title_json = json.loads(chat_summary_and_title)

        else :
            print("is not valid")        
        
        print("text_context_response ", chat_summary_and_title_json)
        return JSONResponse(status_code=200, content={ "summary": chat_summary_and_title_json['summary'], "title": chat_summary_and_title_json['title']})
    except Exception as e:  
        raise HTTPException(status_code=500, detail=str(e))
    

# Route to render the documentation
@app.get("/documentation", response_class=HTMLResponse)
async def custom_docs():
    with open("docs.md", "r") as f:
        content = f.read()
    html_content = markdown.markdown(content)
    return f"""
    <!DOCTYPE html>
    <html>

    <body>
       
        {html_content}
    </body>
    </html>
    """

@app.get('/voyage/embed')
async def voyage_embed(query: str):
    return vo.embed(query,model="voyage-large-2-instruct")


@app.post("/search")
async def search(request: SearchRequest):
    res = await search_web(request)
    return JSONResponse(status_code=200, content={"results": res})
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

@app.middleware("http")
async def log_requests(request: Request, call_next):
    # Log the request method and URL
    print(f"Incoming request: {request.method} {request.url}")
    
    # Log headers for further investigation
    print(f"Headers: {request.headers}")
    
    # Process the request
    response = await call_next(request)
    
    return response

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)

def is_valid_json(text):
    try:
        json.loads(text)
        return True
    except ValueError:
        return False


def compress_image(input_path, output_path, max_size_mb=4):
    """
    Compress an image to ensure its size is below the specified max size in MB.
    
    Args:
        input_path (str): Path to the input image.
        output_path (str): Path to save the compressed image.
        max_size_mb (int): Maximum allowed size in MB.
    """
    max_size_bytes = max_size_mb * 1024 * 1024  # Convert MB to bytes
    quality = 95  # Initial quality for compression

    # Open the image
    img = Image.open(input_path)
    
    # Check the file size
    img.save(output_path, format=img.format, quality=quality)
    while os.path.getsize(output_path) > max_size_bytes:
        # Reduce quality
        quality -= 5
        if quality < 10:  # Prevent going too low in quality
            raise ValueError("Cannot compress image to below 4MB without significant quality loss.")
        
        # Save the image with reduced quality
        img.save(output_path, format=img.format, quality=quality)

    print(f"Image compressed to {os.path.getsize(output_path) / (1024 * 1024):.2f} MB at quality {quality}")
