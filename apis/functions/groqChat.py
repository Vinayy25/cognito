import os
import redis
from fastapi import HTTPException
from redis_functions import get_chat_history, store_chat_history
from functions.similaritySearch import getSimilarity
from templates import gemini_system_prompt, system_prompt_without_rag
from helpers.formatting import list_to_numbered_string
from groq import Groq
import asyncio
from tts_deepgram import get_audio_deepgram
from dotenv import load_dotenv

load_dotenv()
# Set up the Groq client
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))
groq_model_name = os.environ.get("GROQ_MODEL")
non_reasoning_model = os.environ.get("GROQ_MODEL_WITHOUT_REASONING")

def stream_groq_response_with_audio(user: str, id: str, query: str, r: redis.Redis, embed_model):
    similarDocs = getSimilarity(query=query, user=user, conversation_id=id, embed_model=embed_model)
    similarText = list_to_numbered_string(similarDocs)
    systemMessage = gemini_system_prompt + similarText 
    print("System message: ", systemMessage)

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

    # Check if roles are valid before calling Groq API
    print("Formatted chat history:", chat_history)

    # Make the API call and stream the response
    response_stream = client.chat.completions.create(
        model="llama-3.2-90b-vision-preview",
        messages=chat_history,
        
        stream=True
    )

    audio_files = []
    buffer = ""
    buffer_limit = 100  # Set a sensible buffer limit (e.g., 1000 characters)

    for chunk in response_stream:
        assistant_response_chunk = chunk.choices[0].delta.content
        print("Assistant response chunk:", assistant_response_chunk)

        if assistant_response_chunk:
            buffer += assistant_response_chunk
            # Check if buffer has reached the limit
            if len(buffer) >= buffer_limit:
                # Generate a unique filename using user, id, and a timestamp
                timestamp = int(time.time() * 1000)
                audio_filename = f"{user}_{id}_{timestamp}_{len(audio_files)}.wav"
                audio_file = get_audio_deepgram(buffer, audio_filename)
                audio_files.append(audio_file)
                buffer = ""  # Reset the buffer

        # Store each chunk in chat history in Redis
        store_chat_history(username=user, conversation_id=id, text=assistant_response_chunk, role="assistant", r=r)

    # Handle any remaining text in the buffer
    if buffer:
        audio_filename = f"{id}_{len(audio_files)}.wav"
        audio_file = get_audio_deepgram(buffer, audio_filename)
        audio_files.append(audio_file)

    # Store the user query in chat history in Redis
    store_chat_history(username=user, conversation_id=id, text=query, role="user", r=r)

    return audio_files

def groqResponse(user: str, id: str, query: str, r: redis.Redis, embed_model):
    similarDocs = getSimilarity(query=query, user=user, conversation_id=id, embed_model=embed_model)
    similarText = list_to_numbered_string(similarDocs)
    systemMessage = gemini_system_prompt + similarText 
    print("System message: ", systemMessage)

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

    # Check if roles are valid before calling Groq API
    print("Formatted chat history:", chat_history)

    # Make the API call
    response = client.chat.completions.create(
        model=groq_model_name,
        messages=chat_history
    )

    # Append the response to chat history and store it in Redis
    assistant_response = response.choices[0].message.content
    
    store_chat_history(username=user, conversation_id=id, text=query, role="user", r=r)
    store_chat_history(username=user, conversation_id=id, text=assistant_response, role="assistant", r=r)

    return assistant_response

def count_tokens(text: str) -> int:
    """
    Stub function to count tokens in a text.
    Replace this with your actual token counting logic.
    """
    # For example, assume one token per word (this is a rough approximation)
    return len(text.split())

def total_tokens_in_chat(chat_history: list) -> int:
    """
    Returns the total token count for the entire chat history.
    """
    return sum(count_tokens(message["content"]) for message in chat_history)

def truncate_chat_history(chat_history: list, max_tokens: int = 6000) -> list:
    """
    Truncates the chat history by removing the oldest non-system messages
    until the total token count is less than or equal to max_tokens.
    The system message is preserved.
    """
    # Keep the system message (assumed to be the first message)
    system_message = chat_history[0]
    other_messages = chat_history[1:]
    
    # Remove oldest messages until within token limit.
    while other_messages and (count := total_tokens_in_chat([system_message] + other_messages)) > max_tokens:
        # Remove the oldest message (first in list)
        other_messages.pop(0)
    mixed_messages = [system_message] + other_messages
    print("Mixed messages: ", mixed_messages)
    return mixed_messages

async def stream_groq_response(user: str, id: str, query: str, word_length: int, r: redis.Redis, embed_model, perform_rag: str, reasoning: bool):
    if perform_rag == "true":
        similarDocs = getSimilarity(query=query, user=user, conversation_id=id, embed_model=embed_model)
        similarText = list_to_numbered_string(similarDocs)
        systemMessage = gemini_system_prompt + similarText + " Make sure to answer in less than " + str(word_length) + " words"
    else:
        systemMessage = gemini_system_prompt + """ For straightforward questions, respond concisely in less than 50 words.
For explanatory or complex questions, provide a detailed answer, but keep the response within 200 words.
Be mindful of clarity and precision in your explanations, ensuring all relevant details are covered within the word limit.
""" 

    # Initialize chat history with system message for Groq  
    chat_history = [{"role": "system", "content": systemMessage}]
    
    # Load previous chat history from Redis and format for Groq
    previous_chats = get_chat_history(user, id, r)
    for entry in previous_chats:
        role = entry.get("role")
        if role not in {"user", "assistant"}:
            print(f"Invalid role '{role}' in chat history. Skipping this entry.")
            continue
        # Assuming that each entry has at least one part with a "text" key
        chat_history.append({"role": role, "content": entry["parts"][0]["text"]})
    
    # Add the current user query to the chat history
    chat_history.append({"role": "user", "content": query})
    
    # Truncate the chat history if it exceeds the token limit of 6000
    chat_history = truncate_chat_history(chat_history, max_tokens=3000)
    
    try :
        model = groq_model_name if reasoning else non_reasoning_model
        # Make the API call and stream the response
        response = client.chat.completions.create(
            model=model,
            messages=chat_history,
            stream=True,
        )
        
        assistant_response = ""

        for chunk in response:
            text = chunk.choices[0].delta.content

            if chunk.choices[0].finish_reason:
                store_chat_history(username=user, conversation_id=id, text=query, role="user", r=r)
                store_chat_history(username=user, conversation_id=id, text=assistant_response, role="assistant", r=r)
                break
            else:
                assistant_response += text
                yield text
    except Exception as e:
        print("Error in streaming response: ", e)
        raise HTTPException(status_code=500, detail="Error in streaming response")

