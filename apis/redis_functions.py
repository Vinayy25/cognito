


import json 
from typing import Any, List

from redis import Redis
def store_chat_history(username, conversation_id, text, role, r):
    key = f"{username}:{conversation_id}"
    
    # If the marker </think> is present, remove everything before it (including the marker)
    marker = "</think>"
    if marker in text:
        # Split once at the marker and take the part after it
        text = text.split(marker, 1)[1]
    
    # Retrieve existing chat history
    existing_history = r.get(key)
    if existing_history:
        chat_history = json.loads(existing_history)
    else:
        chat_history = []

    # Add new parts to the chat history
    new_entry = {"role": role, "parts": [{"text": text}]}
    chat_history.append(new_entry)

    # Store updated chat history back to Redis
    r.set(key, json.dumps(chat_history))
def get_chat_history(username : str, conversation_id : str, r : Redis):
    if r is None or not r.ping():  # Check if r is None or disconnected
        print("Redis client is not connected.")
        print(r)
        
    key = f"{username}:{conversation_id}"
    stored_data = r.get(key)
    if stored_data:
        return json.loads(stored_data)
    return []