

import pvporcupine
import pyaudio
import struct
import threading
from playsound import playsound
from request_server import send_audio_and_get_response_play
import pygame
from main import record_audio_sounddevice

prompt_audio_file = "prompt.mp3"

def play_my_sound():
    pygame.mixer.init()
    pygame.mixer.music.load("audio2.wav")
    pygame.mixer.music.play()


def play_sound():
    def play():
        playsound("audio2.wav")
    sound_thread = threading.Thread(target=play)
    sound_thread.start()

def main():
    # Initialize Porcupine with a chosen wake word (e.g., "porcupine")

    porcupine = pvporcupine.create(
        access_key='pFaTLsJqVDE6/uSXFftK07tDKzwK6JaLnVAGH5nwvAl3W+oF6sO58Q==',
        keywords=['snowboy',]
    )
    

    # Configure audio input stream
    pa = pyaudio.PyAudio()
    audio_stream = pa.open(
        rate=porcupine.sample_rate,
        channels=1,
        format=pyaudio.paInt16,
        input=True,
        frames_per_buffer=porcupine.frame_length
    )

    print("Listening for wake word...")

    try:
        while True:
            # Read audio data from microphone
            pcm = audio_stream.read(porcupine.frame_length, exception_on_overflow=False)
            pcm = struct.unpack_from("h" * porcupine.frame_length, pcm)

            # Check if the wake word is detected
            result = porcupine.process(pcm)
            if result >= 0:
                print("Wake word detected!")
                play_my_sound()
                
                record_audio_sounddevice(prompt_audio_file,10) 
                send_audio_and_get_response_play(prompt_audio_file)
    except KeyboardInterrupt:
        print("Stopping...")

    finally:
        # Cleanup resources
        audio_stream.close()
        pa.terminate()
        porcupine.delete()


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


