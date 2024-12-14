import pyaudio
import wave
import requests
import pygame
import sounddevice as sd
from scipy.io.wavfile import write


# Configuration
USER_ID = "user123"  # Replace with actual user ID
CONVERSATION_ID = "conv456"  # Replace with actual conversation ID
MODEL_TYPE = "text"  # Default: "text"
PERFORM_RAG = "false"  # Default: "false"
AUDIO_FILE_NAME = "testaudio.ogg"  # Temporary file for recorded audio
API_ENDPOINT = "http://cognito.fun/audio-chat-stream"  # Replace with actual endpoint

# Audio settings
FORMAT = pyaudio.paInt16
CHANNELS = 2
RATE = 64000
CHUNK = 1024
RECORD_SECONDS = 5
def record_audio_sounddevice(filename, duration, sample_rate=44100):
    """
    Records audio and saves it as a WAV file.
    
    :param filename: Name of the file to save (e.g., 'output.wav')
    :param duration: Recording duration in seconds
    :param sample_rate: Sample rate (default 44100 Hz)
    """
    print(f"Recording for {duration} seconds...")
    audio_data = sd.rec(int(duration * sample_rate), samplerate=sample_rate, channels=2, dtype='int16')
    sd.wait()  # Wait until recording is finished
    write(filename, sample_rate, audio_data)
    print(f"Recording saved to {filename}")
def record_audio(file_name):
    """Records audio from the microphone and saves it to a file."""
    print("Recording...")
    audio = pyaudio.PyAudio()
    stream = audio.open(format=FORMAT, 
                        input_device_index=1,
                        channels=CHANNELS,
                        rate=RATE, input=True, frames_per_buffer=CHUNK)
    frames = []

    for _ in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
        data = stream.read(CHUNK)
        frames.append(data)

    print("Recording finished.")
    stream.stop_stream()
    stream.close()
    audio.terminate()

    with wave.open(file_name, 'wb') as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(audio.get_sample_size(FORMAT))
        wf.setframerate(RATE)
        wf.writeframes(b''.join(frames))

def send_audio_and_get_response(file_name):
    """Sends the recorded audio to the API endpoint and streams the response."""
    print("Sending audio file to the server...")
    with open(file_name, 'rb') as audio_file:
        files = {'audio_file': audio_file}
        params = {
            'user': USER_ID,
            'id': CONVERSATION_ID,
            'model_type': MODEL_TYPE,
            'perform_rag': PERFORM_RAG
        }
        response = requests.get(API_ENDPOINT, params=params, files=files, stream=True)

    if response.status_code == 200:
        print("Audio response received.")
        return response
    else:
        print(f"Error {response.status_code}: {response.text}")
        return None


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

def main():
    try: 
        # Step 1: Record audio
        # record_audio(AUDIO_FILE_NAME)

        # Step 2: Send audio and get the response
        response = send_audio_and_get_response(AUDIO_FILE_NAME)
        if response:
            # Step 3: Play the audio response
            play_audio_response(response)


    except Exception as e:
        print("An error occurred:", str(e))

if __name__ == "__main__":
    main()
