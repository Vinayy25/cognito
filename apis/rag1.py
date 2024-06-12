import requests 
from langchain.vectorstores import Chroma
from langchain_core.output_parsers import StrOutputParser
import chromadb, json, uuid

url = "https://1f95-2409-40f2-301a-2232-624c-6bd-da22-dd62.ngrok-free.app"

text = """Lawyer A (Prosecution): Your Honor, the evidence presented clearly indicates a case of dowry harassment. The defendant, Mr. Kapoor, has not only failed to provide the promised marital home but has also subjected the victim, Ms. Iyer, to constant mental and emotional abuse for failing to meet his exorbitant dowry demands.
Lawyer B (Defense): Objection! My client, Mr. Kapoor, vehemently denies these accusations. The gifts in question were willingly offered by the Iyer family, and there was no coercion involved. Ms. Iyer is attempting to malign my client's character after their unfortunate marital discord.
Lawyer A: Your Honor, with all due respect, the documentation clearly outlines the specific items demanded as dowry by Mr. Kapoor's family before the wedding. We also have witness testimonies from neighbours who can attest to the constant arguments and harassment Ms. Iyer faced regarding the unmet dowry demands.
Lawyer B: My client maintains his innocence. These accusations are merely a ploy by Ms. Iyer to claim a larger share of marital assets during the divorce proceedings. We have counter-testimonies that depict a loving relationship between the couple before the alleged dowry disputes arose.
Lawyer A:  If there was a loving relationship, Your Honor, why would Ms. Iyer be forced to leave the marital home and seek refuge with her family? The emotional trauma she suffered is evident from the medical reports we have submitted.
"""

parser = StrOutputParser()


chroma_client = chromadb.HttpClient(host='localhost', port=3000,)
collection = chroma_client.get_or_create_collection(
    name = "my_collection1",
)


systemMessage= """
        These transcripts contain information about your user. 
        Your task is to organize the information in a way that makes sense to you.
        Your response must be in json format with only the two following keys: "summary", "topics".
        Do not inclue any line breaks or special characters in your response.
    """
message =  text + """\n\nGiven the information about the user, provide a summary, and the topics discussed.\n
        *** Summary must be a brief overview of the transcript.\n\n
        *** Topics must be a list of topics that were discussed in the transcript, include topics not mentioned but that relate to the topics discussed.\n\n
         """ 



text_context_response = requests.post(
    url+"/chat",
    params= {
        "message": message,
        "systemMessage": systemMessage
    }
)


text_context = text_context_response.json()['response']
print("text_context ", text_context)
jsonResponse = json.loads(text_context)
summary = jsonResponse['summary']
topics = jsonResponse['topics']
topics_json = json.dumps(topics)
print("summary ",summary)
print("topics ",topics)

response = requests.post(
    url+"/embeddings/",

    params={
        "request":""" Raw Text: {text}, This is an summary of the broader conversation so you have more context {summary}, and Topics pertaining to the conversation {topics}"""
    }
)



embeddings=(response.json()["embeddings"])
# print("embeddings ", embeddings)



documents = [text]
metadatas = [{'summary': summary, 'topics': topics_json}]
collection.add(
    documents = documents,
    embeddings = embeddings,
    metadatas = metadatas,
    ids = [ str(uuid.uuid4() )]
)

# myembeddings = collection.get(
#     ids = [str(2222)],
#     include= ['embeddings']
  
# )

# print("myembeddings ",myembeddings["embeddings"])



newPrompt = "basketball game"




response = requests.post(
    url+"/embeddings/",
    params={
        "request":newPrompt
    }

)

promptEmbeddings=(response.json()["embeddings"])

# print("promptEmbeddings ", promptEmbeddings)

similarities = collection.query(
    query_embeddings=promptEmbeddings,
            n_results=2,
)



# print("similarities ", similarities)

summary = similarities['metadatas'][0][0]['summary']
topics = similarities['metadatas'][0][0]['topics']
text = similarities['documents'][0][0]

final_sys_prompt = """
      You are the most helpful and advanced personal assistant ever, helping the user navigate through life and be brief. 
      He is asking you questions, and you answer them with the best of your ability.
      You have access to some of their records, to help you answer their question in a more personalized way.
      Records:
        this is the summary :"""+summary+"""
        these are the topics covered :"""+topics+"""
      Use the summary and topics covered to generate your response more personalised. Do not include that you are referring to the record given to you
      Make sure to add more related information to the generated response.
      If the records provided happens to be completly unrelated to the prompt asked ,refrain from using the records provided
      Respond in a very natural way.
      UNDERSTOOD
"""
print('\n\n\n')
print("summary" , summary )
print("topics" , topics )
print("text" , text )
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

