import requests
import json
import os

from dotenv import load_dotenv
load_dotenv()






def getAudioFromNeets(text : str, filename : str):
    response = requests.request(
        method="POST",
        url="https://api.neets.ai/v1/tts",
        headers={
            "Content-Type": "application/json",
            "X-API-Key": os.getenv("NEETS_API_KEY")
        },
        json={
            "text": text,
            "voice_id": "vits-eng-1",
            "params": {
                "model": "ar-diff-50k"
            }
        }
    )

    with open(filename, "wb") as f:
        f.write(response.content)

    return filename


