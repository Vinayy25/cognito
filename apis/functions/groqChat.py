import os
import redis
from fastapi import HTTPException
from redis_functions import get_chat_history, store_chat_history
from functions.similaritySearch import getSimilarity
from templates import gemini_system_prompt
from helpers.formatting import list_to_numbered_string
from groq import Groq

# Set up the Groq client
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

# def groqResponse(user: str, id: str, query: str, r: redis.Redis, embed_model):
#     similarDocs = getSimilarity(query=query, user=user, conversation_id=id, embed_model=embed_model)
#     similarText = list_to_numbered_string(similarDocs)
#     systemMessage = gemini_system_prompt + similarText 
#     print("System message: ", systemMessage)

#     # Initialize chat history with system message for Groq
#     chat_history = [{"role": "system", "content": systemMessage}]
    
#     # Load previous chat history from Redis and format for Groq
#     previous_chats = get_chat_history(user, id, r)
#     for entry in previous_chats:
#         chat_history.append({"role": entry["role"], "content": " ".join(part["text"] for part in entry["parts"])})

#     # Append the user query to the chat history
#     chat_history.append({"role": "user", "content": query})

#     # Generate a response using Groq
#     response = client.chat.completions.create(
#         model="llama-3.2-90b-vision-preview",
#         messages=chat_history,

#     )

#     # Extract and store response
#     assistant_response = response.choices[0].message.content
#     chat_history.append({"role": "assistant", "content": assistant_response})
    
#     # Store chat history in Redis
#     store_chat_history(username=user, conversation_id=id, text=query, role="user", r=r)
#     store_chat_history(username=user, conversation_id=id, text=assistant_response, role="assistant", r=r)
    
#     return assistant_response


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
        model="llama-3.2-90b-vision-preview",
        messages=chat_history,
        max_tokens=200

    )

    # Append the response to chat history and store it in Redis
    assistant_response = response.choices[0].message.content
    
    store_chat_history(username=user, conversation_id=id, text=query, role="user", r=r)
    store_chat_history(username=user, conversation_id=id, text=assistant_response, role="assistant", r=r)

    return assistant_response
