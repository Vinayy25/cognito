import os, faiss
from typing import List
from langchain_community.vectorstores import FAISS
from templates import smvitm_data

def save_embeddings(text : List[str] , user: str, conversation_id: str, embed_model):

     # collections_folder = os.path.join(os.path.dirname(__file__), '..', 'collection')
    faiss_index_file = os.path.join(os.path.dirname(__file__), 'collection',  '_'+user+'_'+conversation_id)

    
    if os.path.exists(faiss_index_file)==False:
        print("User does not exist")
        db = FAISS.from_texts([smvitm_data],embed_model)
        db.save_local(faiss_index_file)
        print("User created")

    db = FAISS.load_local(faiss_index_file , embed_model, allow_dangerous_deserialization=True  )
    db.add_texts(text)
    print("reached here")
    db.save_local(faiss_index_file)
    print("Embeddings saved")



def create_new_user(user: str, conversation_id: str, embed_model):
    faiss_index_file = os.path.join(os.path.dirname(__file__), 'collection',  '_'+user+'_'+conversation_id)
    db = FAISS.from_texts([smvitm_data],embed_model)
    db.save_local(faiss_index_file)

    