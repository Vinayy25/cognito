import os, faiss
from typing import List
from langchain_community.vectorstores import FAISS

from langchain_huggingface import HuggingFaceEmbeddings


def save_embeddings(text : List[str] , user: str, conversation_id: str, embed_model):

    collections_folder = os.path.join(os.path.dirname(__file__), '..', 'collection')
    faiss_index_file = os.path.join(collections_folder, user, conversation_id)

    
    if os.path.exists(faiss_index_file)==False:
        print("User does not exist")
        db = FAISS.from_texts(["vvv"],embed_model)
        db.save_local(faiss_index_file)
        print("User created")




    db = FAISS.load_local(faiss_index_file , embed_model, allow_dangerous_deserialization=True  )
    db.add_texts(text)


    db.save_local(faiss_index_file)



if __name__ == "__main__":
    embed_model = HuggingFaceEmbeddings(
    model_name="Alibaba-NLP/gte-Qwen2-1.5B-instruct",
    )
    save_embeddings(["lets do some timepass"], "viya", '12345675432', embed_model=embed_model)
    