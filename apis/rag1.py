import requests 
from langchain.vectorstores import Chroma
import chromadb, json, uuid

url = "https://c15d-2401-4900-33d8-e546-e9d5-c4e2-cde4-6b66.ngrok-free.app"

text = """Hey, did you catch the basketball game last night? It was incredible! The game was between the Lakers and the Celtics.
LeBron James was on fire! He scored 40 points, including a last-minute three-pointer that sealed the victory. 
In the third quarter, LeBron made this insane alley-oop dunk that had the entire arena on their feet. 
The pass came from Anthony Davis, who was being double-teamed, and somehow, LeBron just soared through the air and slammed it down.
It was like watching a scene from a movie. Jayson Tatum was the star for the Celtics. 
He managed to score 35 points and had some incredible drives to the basket. 
There was one moment where he crossed over two defenders and made a reverse layup that had everyone cheering. 
The crowd was electric. Every time someone made a big play, the noise was deafening.
And during halftime, they had this cool drone light show that displayed highlights from past games.
It was really impressive. At the end of the game, there was this wholesome moment where LeBron gave his shoes to a young fan in the crowd. 
The kid was over the moon, and the whole stadium applauded. It was a great way to cap off an already thrilling night"""


text1 = """Back in the 1990s, my biology class was an eye-opening experience for many students. As Professor Harikrishna, 
I took immense pride in guiding young minds through the fascinating world of life sciences. We delved deep into the study 
of life and living organisms, exploring diverse fields such as botany, zoology, microbiology, genetics, and ecology.
 Our journey began at the cellular level, where we examined the intricate structures and functions of cells, the fundamental units of life. Understanding cellular processes like metabolism, cell division, and genetic inheritance was crucial in uncovering the mysteries of biological diversity.

One of the most captivating areas we explored was genetics. I remember the excitement in the classroom as we discussed 
the groundbreaking advancements in this field. Genes, made up of DNA, held the secrets to hereditary information. 
The 1990s saw significant progress, such as the early stages of the Human Genome Project, which aimed to map the entire 
human genome. This project promised new horizons in medicine, with the potential for personalized treatments based on an
 individual's genetic blueprint and the future possibility of gene therapy to correct genetic disorders."""


chroma_client = chromadb.HttpClient(host='localhost', port=3000, )
collection = chroma_client.get_or_create_collection(
    name = "my_collection",
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



print("text_context_response",  text_context_response.json())

text_context = text_context_response.json()['response']
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
print("embeddings ", embeddings)



documents = [text]
metadatas = [{'summary': summary, 'topics': topics_json}]
collection.add(
    documents = documents,
    embeddings = embeddings,
    metadatas = metadatas,
    ids = [str(2222)]
)

myembeddings = collection.get(
    ids = [str(2222)],
    include= ['embeddings']
  
)

print("myembeddings ",myembeddings["embeddings"])












