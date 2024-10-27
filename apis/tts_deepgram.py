import os
from dotenv import load_dotenv

from deepgram import (
    DeepgramClient,
    SpeakOptions,
)

load_dotenv()




#should return a audio file 
def get_audio_deepgram(text : str, filename: str):
    try:
        # STEP 1: Create a Deepgram client using the API key from environment variables
        deepgram = DeepgramClient(api_key=os.getenv("DEEPGRAM_API_KEY"))

        # STEP 2: Configure the options (such as model choice, audio configuration, etc.)
        options = SpeakOptions(
            model="aura-zeus-en",
            encoding="linear16",
            container="wav"
        )

        SPEAK_OPTIONS = {"text": text}
        

        # STEP 3: Call the save method on the speak property
        response = deepgram.speak.v("1").save(filename, SPEAK_OPTIONS, options)
        print(response.to_json(indent=4))
        #return audio response
        return response.filename


    except Exception as e:
        print(f"Exception: {e}")



