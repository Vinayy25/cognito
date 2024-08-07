
import os , faiss

from langchain_community.vectorstores import FAISS

from langchain_huggingface import HuggingFaceEmbeddings



def getSimilarity(query: str , user: str,conversation_id:str, embed_model):

    collections_folder = os.path.join(os.path.dirname(__file__), '..', 'collection')
    faiss_index_file = os.path.join(collections_folder, user,conversation_id)

    if os.path.exists(faiss_index_file)==False:
        print("User does not exist")
        return ""
       

    db = FAISS.load_local(faiss_index_file , embed_model, allow_dangerous_deserialization=True  )
    
    res = db.similarity_search_with_score(
        query,
        k=5
    )

    # Filter out results with a score above 1.5
    filtered_res = [item for item in res if item[1] <= 10]

    # Sort the filtered results by score in ascending order
    # sorted_res = sorted(filtered_res, key=lambda x: x[1])

    # Extract the page_content from the Document objects
    final_result = [doc.page_content for doc, score in filtered_res]

    print(final_result)
    print("result is : ", res)

    return final_result



# if __name__ == "__main__":
#     embed_model = HuggingFaceEmbeddings(
#     model_name="Alibaba-NLP/gte-Qwen2-1.5B-instruct",
#     )
#     print("Using model:  ",embed_model.model_name)
#     getSimilarity("what is timepass", "viya", embed_model=embed_model)