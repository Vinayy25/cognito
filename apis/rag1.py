import requests 
from langchain.vectorstores import Chroma
from langchain_core.output_parsers import StrOutputParser
import chromadb, json, uuid
from langchain.vectorstores import Qdrant
from langchain_community.embeddings.fastembed import FastEmbedEmbeddings

url = "https://af47-2401-4900-4e6a-eb83-9969-6e06-3ea-b736.ngrok-free.app"


texts = [
    "Customer: 'Hi, I received a damaged product. Can you help me with a replacement?' Agent: 'I'm sorry to hear that. Can you provide your order number and a photo of the damaged item?'",
    "User: 'My laptop isn't turning on. What should I do?' Support: 'Please try holding down the power button for 10 seconds. If that doesn't work, check if the charger is properly connected.'",
    "Traveler: 'Can you help me book a flight to Paris for next month?' Agent: 'Sure! Do you have specific dates in mind for your travel?'",
    "Patient: 'I need to schedule a check-up with Dr. Smith.' Receptionist: 'Dr. Smith has openings next Monday and Wednesday. Which day works better for you?'",
    "Diner: 'I'd like to reserve a table for four at 7 PM tonight.' Host: 'We have availability at 7 PM. Can I have your name and contact number, please?'",
    "Parent: 'Can you tell me about the enrollment process for kindergarten?' Administrator: 'Certainly! You'll need to fill out an application form and provide your child's birth certificate and immunization records.'",
    "Customer: 'How can I apply for a home loan?' Banker: 'You can apply online or visit any of our branches. Do you need assistance with the application process?'",
    "Candidate: 'Can you tell me more about the responsibilities of this role?' Interviewer: 'Certainly! The primary responsibilities include managing the team, overseeing project timelines, and ensuring quality control.'",
    "Patron: 'Do you have any books on machine learning?' Librarian: 'Yes, we have several. I can show you to the section or help you search the catalog.'",
    "Client: 'I'm looking to lose weight and build muscle. Can you help me with a workout plan?' Coach: 'Absolutely! We can start with a consultation to assess your current fitness level and set some goals.'"
]


parser = StrOutputParser()


# chroma_client = chromadb.HttpClient(host='localhost', port=3000,)
# collection = chroma_client.get_or_create_collection(
#     name = "my_collection9",
    
# )

embeddings = FastEmbedEmbeddings(model_name="BAAI/bge-base-en-v1.5")



for text in texts:

    systemMessage= """
        These transcripts contain information about your user. 
        Given the information about the user, provide a summary, and the topics discussed
        Your response must strictly be in JSON format with only the two following keys: "summary", "topics".
        Summary must be a brief overview of the transcript,
        Topics must be a list of topics that were discussed in the transcript, include topics not mentioned but that relate to the topics discussed
        Use double quotes to represent topics , do not use single quotes and make sure to verify the json structure.
        Do not inclue any line breaks or special characters in your response.
    """
    message =  text
    
    try:
        text_context_response = requests.post(
        url+"/groq/chat",
        params= {
        "message": message,
        "systemMessage": systemMessage
        }
        )
        if(text_context_response.status_code != 200):
            print("error ", text_context_response.text)
            

    except Exception as e:
        print("error ", e)
    


    text_context = text_context_response.json()['response']
    print("text_context ", text_context)
    jsonResponse = json.loads(text_context)
    summary =(jsonResponse['summary'])
   

   

    topics = " ".join(jsonResponse['topics'])
    print("summary ",summary)
    print("topics ",topics)

    # response = requests.get(
    # url+"/embeddings/alibaba",
    
    # params={
    # "request":"""{summary}"""
    # }
    # )



    # embeddings=(response.json()["embeddings"])
    # print("embeddings ", embeddings)



    documents = text
    metadatas = [{'summary': summary, 'topics': topics}]
    # collection.add(
    # documents = documents,
    # embeddings = embeddings,
    # metadatas = metadatas,
    # ids = [ str(uuid.uuid4() )]
    # )

    docs = documents
    qdrant = Qdrant.from_texts(
    docs,
    embeddings,
    # location=":memory:",
    path="./database",
    collection_name="document_embedding",
)
    

# myembeddings = collection.get(
#     ids = [str(2222)],
#     include= ['embeddings']
  
# )

# print("myembeddings ",myembeddings["embeddings"])



newPrompt = "im not feeling well, probably i need to go for a checkup"



# response = requests.get(
#     url+"/embeddings/alibaba",
#     params={
#         "request":newPrompt
#     }

# )

# promptEmbeddings=(response.json()["embeddings"])

# print("promptEmbeddings ", promptEmbeddings)

# similarities = collection.query(
#     query_embeddings=promptEmbeddings,
#             n_results=1,
# )
query = newPrompt
retriever = qdrant.as_retriever(search_kwargs={"k": 5})
retrieved_docs = retriever.invoke(query)

for doc in retrieved_docs:
    print(f"id: {doc.metadata['_id']}\n")
    print(f"text: {doc.text[:256]}\n")
    print("-" * 80)
    print()


# print("similarities ", similarities)

summary = retrieved_docs.text

# summary = similarities['metadatas'][0][0]['summary']
# topics = similarities['metadatas'][0][0]['topics']
# text = similarities['documents'][0][0]


summary =retrieved_docs
final_sys_prompt = """
You are an advanced personal assistant dedicated to helping users navigate their lives with precise, informative, and brief responses. When answering questions, leverage the provided records to personalize your responses, but do not mention the records explicitly.

Your guidelines are:
1. Use the summary and topics from the records to personalize your response.
2. Incorporate additional relevant information to enhance your answers.
3. If the records provided are unrelated to the user's prompt, do not use them.
4. Respond in a natural, conversational tone.

UNDERSTOOD.

Below are some records to help you answer the user's question. The relevance of the records decreases as you move down the list. Use them only if they are appropriate to the prompt:

Records: {summary}
"""

print('\n\n\n')

print("similarity summary" , summary )

print('\n\n\n')



final_response = requests.get(
    url+"/gemini",
    params= {
        "query": newPrompt,
        "systemMessage": final_sys_prompt
    },
    stream=True
)

# print("final sys prompt " , final_sys_prompt)


print("\n\n\n")
print("Streaming response:")
for chunk in final_response.iter_content(chunk_size=None):
    print(chunk.decode('utf-8'), end='')



#again storing back the response in db so that it will have a relation lateron 


