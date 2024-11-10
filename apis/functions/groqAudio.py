import os
from groq import Groq
import dotenv

dotenv.load_dotenv()

# Initialize the Groq client
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))


def translate_audio(file_path):
    # Specify the path to the audio file
    filename = file_path

    # Open the audio file
    with open(filename, "rb") as file:
        # Create a translation of the audio file
        translation = client.audio.translations.create(
            file=(filename, file.read()),  # Required audio file
            model="whisper-large-v3",  # Required model to use for translation
            response_format="json",  # Optional
            temperature=0.0,  # Optional
          
        )
        # Return the translation text
        return translation.text
