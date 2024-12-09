import pigpio
import pyaudio
import wave


FORMAT = pyaudio.paInt16
CHANNELS = 1  # Mono input
RATE = 44100  # Sampling rate
CHUNK = 1024  # Frames per buffer
RECORD_SECONDS = 4
OUTPUT_FILENAME = "output.wav"
# Initialize PyAudio
audio = pyaudio.PyAudio()

# Initialize variables for recording
stream = None
frames = []
isRecording = False  # Flag to track recording state

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

# Connect to pigpio daemon
pi = pigpio.pi()
if not pi.connected:
    print("Failed to connect to pigpio daemon.")
    exit()

GPIO_PIN = 27  # Replace with your GPIO pin number
pi.set_mode(GPIO_PIN, pigpio.INPUT)
pi.set_pull_up_down(GPIO_PIN, pigpio.PUD_DOWN)

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
