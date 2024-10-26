

import redis
from fastapi import HTTPException
from  redis_functions import get_chat_history, store_chat_history
from functions.similaritySearch  import getSimilarity
from functions.genModel import get_generative_model
from templates import gemini_system_prompt
from helpers.formatting import  list_to_numbered_string


def geminiResponse( user: str, id: str, query: str, model_type: str, r: redis.Redis, embed_model):
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
    return chat_response
    