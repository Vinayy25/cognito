import pyaudio
import wave
import requests
import pygame
import sounddevice as sd

import struct
from scipy.io.wavfile import write
from silence_detect import detect_silence_and_stop


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
    #wait for min of 1 sec before stopping
    
    sd.wait(detect_silence_and_stop())  # Wait until recording is finished
    

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

if __name__ == "__main__":
    main()
