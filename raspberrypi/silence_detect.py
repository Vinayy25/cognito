import pyaudio
import struct
import sounddevice as sd
import time
import pygame

def detect_silence_and_stop(threshold=200, silence_duration= 0.5, sample_rate=16000, chunk_size=1024):
    print("detecting silence")
    """
    Detects silence in the audio stream.
    
    :param threshold: Amplitude below which audio is considered silence
    :param silence_duration: Duration (in seconds) of continuous silence to stop detection
    :param sample_rate: Audio sample rate (default: 16000 Hz)
    :param chunk_size: Number of frames per buffer (default: 1024)
    :return: None
    """
    #wait for min of 1 sec before stopping
    time.sleep(1)
    
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
            print(max_amplitude)
            if max_amplitude < threshold:
                silent_chunks += 1
            else:
                silent_chunks = 0

            if silent_chunks >= silence_duration * (sample_rate / chunk_size):
                print("Silence detected. Stopping...")
                sd.stop()
                pygame.mixer.init()
                pygame.mixer.music.load("audio2.wav")
                pygame.mixer.music.play()
                #return a callback to sd.wait()
                return True
                break
    except KeyboardInterrupt:
        print("Stopped manually.")
    finally:
        stream.stop_stream()
        stream.close()
        pa.terminate()


