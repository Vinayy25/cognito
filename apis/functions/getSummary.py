from typing import List
import requests
import json, uuid



def getSummaryUsingGroq(texts: List[str]): 
    localUrl = "http://localhost:8000"
    summarisedTexts = {}
    for i in range(len(texts)):
        text = texts[i]
        print("Processing text:", text)

        systemMessage = """
            These transcripts contain information about your user. 
            Your task is to organize the information in a way that makes sense to you.
            Your response must be in json format with only the two following keys: "summary", "topics".
            Do not inclue any line breaks or special characters in your response.
            Strictly check and validate if it is a valid JSON structure.
            Don't include any other keys or text in the response, avoid line breaks.
            Don't include backslashes in the response
        """
        message = text + """
            \n\nGiven the information about the user, provide a summary, and the topics discussed.\n
            *** Summary must be a brief overview of the transcript.\n\n
            *** Topics must be a list of topics that were discussed in the transcript, include topics not mentioned but that relate to the topics discussed.\n\n
        """
        
        while True:
            try:
                print("Sending POST request to /groq/chat")
                text_context_response = requests.get(
                    "http://localhost:8000/groq/chat/",
                    params={
                        "message": message,
                        "systemMessage": systemMessage
                    },
                    headers={
                        'accept': 'application/json'
                    },
                    
                )


                print("Received response from POST request")
                text_context = text_context_response.json()['response']
                print("Response content:", text_context)

                if is_valid_json(text_context):
                    break
                else:
                    print(f"Invalid JSON format received: {text_context}")
                    correction_message = f"""
                        The response provided was not a valid JSON structure. Please reformat the response to ensure it is a valid JSON with keys 'summary' and 'topics' only. 
                        Remove any line breaks or special characters from the response. 
                        Remove backslashes from the response.
                        Here is the response you provided:
                        {text_context}
                    """
                    correction_system_message = """
                        These transcripts contain information about your user. Please make the corrections as said and only respond with a valid json body
                    """

                    correction_response = requests.get(
                        "http://localhost:8000/groq/chat/",
                        params={
                            "message": correction_message,
                            "systemMessage": correction_system_message
                        },
                        headers={
                            'accept': 'application/json'
                        },
                       
                    )

                    print("Received correction response")
                    text_context = correction_response.json()['response']
                    if is_valid_json(text_context):
                        break

            except requests.exceptions.RequestException as e:
                print(f"Request failed: {e}")
                return None

        jsonResponse = json.loads(text_context)
        summary = jsonResponse['summary']
        topics = jsonResponse['topics']
        topics_json = json.dumps(topics)

        summarisedTexts['summary'] = summary
        summarisedTexts['topics'] = topics_json

        print("Summarised texts:", summarisedTexts)

    return summarisedTexts

def getTitleAndSummary(text: str): 

    localUrl = "http://localhost:8000"
    summarisedTexts = {}
   
    systemMessage= """
            Your response must be in JSON format with only the two following keys: "summary", "topics".
            Do not inclue any line breaks or special characters in your response.
        """
    message =  text + """\n\nGiven the information about the user, provide a summary, and the topics discussed.\n
            *** Summary must be a brief overview of the transcript.\n\n
            *** Topics must be a list of topics that were discussed in the transcript, include topics not mentioned but that relate to the topics discussed.\n\n
            """
    # Repeat until valid JSON response is received
    while True:
            text_context_response = requests.post(
                localUrl + "/groq/chat",
                params={
                    "message": message,
                    "systemMessage": systemMessage
                }
            )
            text_context = text_context_response.json()['response']
            print("text_context_response ", text_context)
            if is_valid_json(text_context):
                break
            else:
                print(f"Invalid JSON format received: {text_context}")

                # Request correction from the API
                correction_message = """The response provided was not a valid JSON structure. Please reformat the response to ensure it is a valid JSON with keys 'summary' and 'topics' only. 
                Remove any line breaks or special characters from the response. 
                Remove backslashes from the response.
                Here is the response you provided:
                {text_context}"""
                
                correction_system_message = """
                    These transcripts contain information about your user. Please make the corrections as said and only respond with a valid json body"""

                correction_response = requests.post(
                    localUrl + "/groq/chat",
                    params={
                        "message": correction_message,
                        "systemMessage": correction_system_message
                    }
                )
                print("correction res: "+correction_response.json()['response'])
                # Use the corrected response for the next iteration
                text_context = correction_response.json()['response']
                if is_valid_json(text_context):
                    break

    jsonResponse = json.loads(text_context)


    summary = jsonResponse['summary']
    topics = jsonResponse['topics']
    topics_json = json.dumps(topics)

    summarisedTexts['summary'] = summary
    summarisedTexts['topics'] = topics_json

    print("summarisedTexts ", summarisedTexts)

    return summarisedTexts


        





def is_valid_json(text):
    try:
        json.loads(text)
        return True
    except ValueError:
        return False

def parse_nested_json(text):
    try:
        # Parse the nested JSON string
        json_data = json.loads(text)
        if 'response' in json_data:
            response_text = json_data['response']
            # Clean up and parse the nested JSON
            clean_response_text = response_text.replace('\\', '')
            return json.loads(clean_response_text)
        return None
    except ValueError:
        return None