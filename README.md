
---

# Cognito

Cognito is an innovative project aimed at providing real-time, context-aware responses by continuously listening to the surroundings. The system comprises a backend and a mobile application, enabling seamless interaction with language models (LLMs). It leverages advanced technologies like FAISS vector databases, Redis caching, Firebase Firestore, and OpenAI Whisper for transcription.

<div style="display: flex; justify-content: space-around; align-items: center; gap: 10px;">
    <img src="/images/cognito_logo.jpeg" alt="Cognito" width="300">
</div>


## Features

- **Continuous Environment Monitoring**: The mobile app records the surroundings, sending audio data to the server.
- **Multi-Language Support**: Utilizes OpenAI Whisper to transcribe audio into text across 99+ languages.
- **Intelligent Response Generation**: Employs FAISS for similarity search, retrieves relevant context, and refines responses using LLMs.
- **Memory Persistence**: Stores information using Redis cache and Firebase Firestore to maintain continuity.
- **Context-Aware Interactions**: Enables users to start a conversation with LLMs that can provide responses based on the recorded surroundings.

<div style="display: flex; justify-content: space-around; align-items: center; gap: 10px;">
    <img src="/images/1.jpeg" alt="App Home Screen" width="200">
    <img src="/images/2.jpeg" alt="Chat Screen" width="200">
    <img src="/images/3.jpeg" alt="Chats" width="200">
    <img src="/images/4.jpeg" alt="Transcription" width="200">
</div>



## Project Structure

The project is divided into two main components:

1. **Backend**: Handles FastAPI endpoints, scripts for data processing, and interaction with vector databases and external services.
2. **Mobile App**: Developed using Flutter, it records audio, sends it to the server, and interacts with LLMs to receive refined responses.

### Backend Structure

- **API Endpoints**: FastAPI-based endpoints to manage data flow between the mobile app and server.
- **Audio Processing**: OpenAI Whisper transcribes audio data into text and breaks it into chunks.
- **Data Storage**:
  - **FAISS Vector Database**: Stores transcribed text as chunks, alongside summaries and topics, for efficient similarity searches.
  - **Redis**: Caches memory for faster retrieval during interactions.
  - **Firebase Firestore**: Persistently stores user data and context.

### Mobile App Structure

- **Audio Recording**: Continuously listens to the surroundings and records audio.
- **Server Communication**: Sends recorded audio data to the backend server.
- **User Interaction**: Initiates conversation with LLMs, which fetch responses based on stored context and provide refined outputs.

## Prerequisites

To run the project, ensure the following are installed:

- Python 3.x
- Ngrok
- Redis
- Flutter SDK

## Getting Started

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Vinayy25/cognito.git
   cd cognito
   ```

2. **Set Up Virtual Environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate # On Windows: venv\Scripts\activate
   ```

3. **Install Required Packages**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the Project**
   Execute the following command to start the server:
   ```bash
   sh start.sh
   ```

5. **Running the Mobile App**
   - Ensure Flutter is installed.
   - Connect a mobile device or emulator.
   - Navigate to the `app/cognito` directory and run:
     ```bash
     flutter run
     ```

## How It Works

1. The mobile app records the environment and sends audio to the backend.
2. The backend uses OpenAI Whisper to transcribe the audio, store it in the FAISS vector database, and create a summary for better similarity searches.
3. When a user initiates a conversation, the app sends a request to the backend, where a similarity search retrieves relevant context from the vector database.
4. The retrieved context is refined and framed by an LLM before sending back a response to the app.
5. The Redis cache is utilized to maintain memory and continuity, while Firebase Firestore securely stores user data.

## Technologies Used

- **Programming Languages**: Python, Dart (Flutter)
- **Frameworks**: FastAPI, Flutter
- **Transcription**: OpenAI Whisper
- **Database**: FAISS Vector Database, Firebase Firestore
- **Caching**: Redis
- **Others**: Ngrok for tunneling

## Contributing

We welcome contributions! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
