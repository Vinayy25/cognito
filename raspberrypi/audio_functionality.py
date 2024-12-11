import pigpio
import pyaudio
import wave

from request_server import send_audio_and_get_response_play, send_audio_rag


FORMAT = pyaudio.paInt16
CHANNELS = 1  # Mono input
RATE = 44100  # Sampling rate
CHUNK = 1024  # Frames per buffer
RECORD_SECONDS = 4
OUTPUT_FILENAME = "output.wav"
RAG_OUTPUT_FILENAME = "rag_output.wav"
GPIO_PIN = 27  # Replace with your GPIO pin number
RAG_GPIO_PIN = 22
# Initialize PyAudio
audio = pyaudio.PyAudio()

# Initialize variables for recording
stream = None
frames = []
isRecording = False  # Flag to track recording state
isPerformingRag = False

def rag_callback(gpio, level, tick):
    global stream, frames, isRecording, isPerformingRag

    if level == 1 and not isRecording and not isPerformingRag:
        print("RAG callback triggered. Starting continuous recording...")
        frames = []  # Reset frames
        stream = audio.open(format=FORMAT,
                            channels=CHANNELS,
                            rate=RATE,
                            input=True,
                            frames_per_buffer=CHUNK)
        isRecording = True
        isPerformingRag = True
        while isRecording:
            # Record for 1 minute
            for _ in range(0, int(RATE / CHUNK * 60)):  # 60 seconds
                if not isRecording:  # Check if recording should stop
                    break
                try:
                    data = stream.read(CHUNK)
                    frames.append(data)
                except OSError as e:
                    print(f"Error reading from stream: {e}")
                    isRecording = False
                    break

            # Save the 1-minute audio chunk
            with wave.open(RAG_OUTPUT_FILENAME, 'wb') as wf:
                wf.setnchannels(CHANNELS)
                wf.setsampwidth(audio.get_sample_size(FORMAT))
                wf.setframerate(RATE)
                wf.writeframes(b''.join(frames))
            print(f"1-minute audio chunk saved to {RAG_OUTPUT_FILENAME}")

            # Send the audio chunk to the server
            send_audio_rag(RAG_OUTPUT_FILENAME)

            # Reset frames for the next chunk
            frames = []

    elif level == 0 and isRecording and isPerformingRag:
        print("RAG callback triggered. Stopping recording...")
        isRecording = False
        stream.stop_stream()
        stream.close()
        stream = None
        isPerformingRag = False
        # Save any remaining audio
        if frames:
            with wave.open(RAG_OUTPUT_FILENAME, 'wb') as wf:
                wf.setnchannels(CHANNELS)
                wf.setsampwidth(audio.get_sample_size(FORMAT))
                wf.setframerate(RATE)
                wf.writeframes(b''.join(frames))
            print(f"Remaining audio chunk saved to {RAG_OUTPUT_FILENAME}")

            # Send the remaining audio chunk to the server
            send_audio_rag(RAG_OUTPUT_FILENAME)

def gpio_callback(gpio, level, tick):
    global stream, frames, isRecording

    if level == 0 and not isRecording:  # Rising edge detected, start recording if not already recording
        print(f"Rising edge detected on GPIO {gpio} at {tick}. Starting recording...")
        frames = []  # Reset frames
        stream = audio.open(format=FORMAT,
                            channels=CHANNELS,
                            rate=RATE,
                            input=True,
                            frames_per_buffer=CHUNK)
        isRecording = True
    elif level == 1 and isRecording:  # Falling edge detected, stop recording if currently recording
        print(f"Falling edge detected on GPIO {gpio} at {tick}. Stopping recording...")
        stream.stop_stream()
        stream.close()
        stream = None
        isRecording = False


        # Save the recorded audio to a .wav file
        with wave.open(OUTPUT_FILENAME, 'wb') as wf:
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(audio.get_sample_size(FORMAT))
            wf.setframerate(RATE)
            wf.writeframes(b''.join(frames))
        print(f"Audio saved to {OUTPUT_FILENAME}")
        send_audio_and_get_response_play(OUTPUT_FILENAME)

# Connect to pigpio daemon
pi = pigpio.pi()
if not pi.connected:
    print("Failed to connect to pigpio daemon.")
    exit()

pi.set_mode(GPIO_PIN, pigpio.INPUT)
pi.set_pull_up_down(GPIO_PIN, pigpio.PUD_DOWN)

pi.set_mode(RAG_GPIO_PIN, pigpio.INPUT)
pi.set_pull_up_down(RAG_GPIO_PIN,pigpio.PUD_DOWN)

rag_cb = pi.callback(RAG_GPIO_PIN,pigpio.EITHER_EDGE,rag_callback)

# Register callback for edge detection
cb = pi.callback(GPIO_PIN, pigpio.EITHER_EDGE, gpio_callback)

try:
    while True:
        if stream is not None:
            try:
                data = stream.read(CHUNK)
                frames.append(data)
            except OSError as e:
                print(f"Error reading from stream: {e}")
                stream = None  # Reset stream to prevent further errors
except KeyboardInterrupt:
    print("Exiting...")
finally:
    cb.cancel()  # Cancel the callback
    pi.stop()    # Disconnect from pigpio
    audio.terminate()
