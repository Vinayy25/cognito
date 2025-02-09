import pyaudio
import wave
import requests
import pygame
import sounddevice as sd

import struct
from scipy.io.wavfile import write
from silence_detect import detect_silence_and_stop


# Configuration
USER_ID = "vinay"  # Replace with actual user ID
CONVERSATION_ID = "12345"  # Replace with actual conversation ID
MODEL_TYPE = "text"  # Default: "text"
PERFORM_RAG = "false"  # Default: "false"
AUDIO_FILE_NAME = "testaudio.ogg"  # Temporary file for recorded audio
API_ENDPOINT = "http://cognito.fun/"  # Replace with actual endpoint

# Audio settings
FORMAT = pyaudio.paInt16
CHANNELS = 2
RATE = 16000
CHUNK = 1024
RECORD_SECONDS = 5
def record_audio_sounddevice(filename, duration, sample_rate=16000):
    """
    Records audio and saves it as a WAV file.
    
    :param filename: Name of the file to save (e.g., 'output.wav')
    :param duration: Recording duration in seconds
    :param sample_rate: Sample rate (default 44100 Hz)
    """
    print(f"Recording for {duration} seconds...")
    audio_data = sd.rec(int(duration * sample_rate), samplerate=sample_rate, channels=2, dtype='int16')
    #wait for min of 1 sec before stopping
    
    sd.wait()  # Wait until recording is finished
    
    
    write(filename, sample_rate, audio_data)
    print(f"Recording saved to {filename}")


def record_audio_sounddevice_for_rag(filename, duration, sample_rate=44100,):
    """Records audio from the microphone and saves it to a file."""
    print(f"Recording for {duration} seconds...")
    #run it on a different thread
   
    audio_data = sd.rec(int(duration * sample_rate), samplerate=sample_rate, channels=2, dtype='int16')
    # #wait for min of 1 sec before stopping

    sd.wait(

    )


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
        url = API_ENDPOINT + "audio-chat-stream"
        response = requests.post(url, params=params, files=files, stream=True)

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


def detect_silence(threshold=30, silence_duration= 0.5, sample_rate=16000, chunk_size=1024):
    """
    Detects silence in the audio stream.
    
    :param threshold: Amplitude below which audio is considered silence
    :param silence_duration: Duration (in seconds) of continuous silence to stop detection
    :param sample_rate: Audio sample rate (default: 16000 Hz)
    :param chunk_size: Number of frames per buffer (default: 1024)
    :return: None
    """
    pa = pyaudio.PyAudio()
    stream = pa.open(
        format=pyaudio.paInt16,
        channels=1,
        rate=sample_rate,
        input=True,
        frames_per_buffer=chunk_size
    )

    print("Listening for user prompt...")

    try:
        silent_chunks = 0
        while True:
            audio_data = stream.read(chunk_size, exception_on_overflow=False)
            pcm = struct.unpack(f'{chunk_size}h', audio_data)
            max_amplitude = max(abs(sample) for sample in pcm)

            if max_amplitude < threshold:
                silent_chunks += 1
            else:
                silent_chunks = 0

            if silent_chunks >= silence_duration * (sample_rate / chunk_size):
                print("Silence detected. Stopping...")
                break
    except KeyboardInterrupt:
        print("Stopped manually.")
    finally:
        stream.stop_stream()
        stream.close()
        pa.terminate()

def send_audio_rag(file_path, user, conversation_id):
    """
    Sends an audio file to the /transcribe/save endpoint.

    :param file_path: Path to the audio file to be sent
    :param user: User identifier
    :param conversation_id: Conversation identifier
    :return: Response from the server
    """
    url = API_ENDPOINT + "transcribe/save"  # Replace with your actual server address
    print(f"Sending audio file to {url}")
    with open(file_path, 'rb') as audio_file:
        files = {'audio_file': audio_file}
        url = url + f"?user={user}&conversation_id={conversation_id}"
        try:
            response = requests.post(url, files=files)
            response.raise_for_status()  # Raise an error for bad responses
            print("Audio file sent successfully.")
            return response.json()  # Assuming the response is in JSON format
        except requests.exceptions.RequestException as e:
            print(f"An error occurred: {e}")
            return None


if __name__ == "__main__":
    main()
