
import requests
import pygame


# Configuration
USER_ID = "vinay"  # Replace with actual user ID
CONVERSATION_ID = "12345"  # Replace with actual conversation ID
MODEL_TYPE = "text"  # Default: "text"
PERFORM_RAG = "false"  # Default: "false"
API_ENDPOINT = "http://cognito.fun/"  # Replace with actual endpoint



def send_audio_and_get_response(file_name, RAG: bool):
    """Sends the recorded audio to the API endpoint and streams the response."""
    print("Sending audio file to the server...")
    with open(file_name, 'rb') as audio_file:
        files = {'audio_file': audio_file}
        if RAG is True:
            perform_rag = "true"
        else:
            perform_rag = "false"
        params = {
            'user': USER_ID,
            'id': CONVERSATION_ID,
            'model_type': MODEL_TYPE,
            'perform_rag': perform_rag
        }
        response = requests.post(API_ENDPOINT+'audio-chat-stream', params=params, files=files, stream=True)

    if response.status_code == 200:
        print("Audio response received.")
        return response
    else:
        print(f"Error {response.status_code}: {response.text}")
        return None
"""
@app.post("/transcribe/save")
async def transcribe_and_save(user: str, conversation_id:str ,audio_file: UploadFile = File(...), ):"""

def send_audio_rag(file_name):
    """
    Sends the recorded audio to the API endpoint and streams the response.
    """
    print("Sending audio file to the server...")
    with open(file_name, 'rb') as audio_file:
        files = {'audio_file': audio_file}
        params = {
            'user': USER_ID,
            'id': CONVERSATION_ID,
            'model_type': MODEL_TYPE,
            'perform_rag': PERFORM_RAG
        }
        requests.post(API_ENDPOINT+'transcribe/save',params=params,files=files)


def play_audio_response(response):
    """Plays the audio response streamed from the server."""
    print("Playing audio response...")

    pygame.mixer.init()
    chunk_size = 4096  # Adjust the chunk size as needed
    temp_file = "temp_audio_stream.wav"

    with open(temp_file, 'wb') as f:
        for chunk in response.iter_content(chunk_size=chunk_size):
            if chunk:
                f.write(chunk)
                f.flush()  # Ensure data is written to disk

                # If mixer is not busy, start playback
                if not pygame.mixer.music.get_busy():
                    pygame.mixer.music.load(temp_file)
                    pygame.mixer.music.play()
    
    # Wait for the playback to finish
    while pygame.mixer.music.get_busy():
        pygame.time.wait(100)

    print("Playback finished.")
    pygame.mixer.quit()


def send_audio_and_get_response_play(file_name, RAG: bool):
    response = send_audio_and_get_response(file_name, RAG)
    if response:
        play_audio_response(response)






def dummy_function_to_check_audio(file_name ):
    #play the audio file arduino.ogg
    pygame.mixer.init()
    pygame.mixer.music.load(file_name)
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy():
        pygame.time.wait(100)
    pygame.mixer.quit()

