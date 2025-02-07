#!/bin/bash

# Update package list
sudo apt update && sudo apt upgrade -y

# Install system dependencies
sudo apt install -y python3-pip python3-dev python3-venv portaudio19-dev libasound2-dev libportaudio2 libportaudiocpp0 ffmpeg

# Install Python dependencies
pip3 install -r requirements.txt

# Additional setup for PvPorcupine
pip3 install pvporcupine pyaudio pygame scipy sounddevice requests playsound
