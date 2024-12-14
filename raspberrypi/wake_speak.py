

import pvporcupine
import pyaudio
import struct
import threading
from playsound import playsound
from request_server import send_audio_and_get_response_play
import pygame
from main import record_audio_sounddevice

prompt_audio_file = "prompt.wav"

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
                record_audio_sounddevice(prompt_audio_file,5)
                send_audio_and_get_response_play(prompt_audio_file)
    except KeyboardInterrupt:
        print("Stopping...")

    finally:
        # Cleanup resources
        audio_stream.close()
        pa.terminate()
        porcupine.delete()

if __name__ == "__main__":
    main()
