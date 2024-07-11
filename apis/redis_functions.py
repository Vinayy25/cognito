


import json 
from typing import Any, List
def store_chat_history(username, conversation_id, text, role, r):
    key = f"{username}:{conversation_id}"
    
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

def get_chat_history(username, conversation_id, r):
    key = f"{username}:{conversation_id}"
    stored_data = r.get(key)
    if stored_data:
        return json.loads(stored_data)
    return []