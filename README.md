
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
- Nginx
- tmux or screen (optional, for managing long-running processes)

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
  sudo apt update
  sudo apt install python3-pip
3. **Install Required Packages**
   ```bash
   pip3 install -r requirements.txt
   ```

4. **Environment Variables**

   Create a `.env` file in the root directory and add the following:

   ```bash
   KRUTRIM_API_KEY=<your_krutrim_api_key>
   GROQ_API_KEY=<your_groq_api_key>
   LOW_RESET=TRUE
   GEMINI_API_KEY=<your_gemini_api_key>
   LLAMA_PARSE_API_KEY=<your_llama_parse_api_key>
   DEEPGRAM_API_KEY=<your_deepgram_api_key>
   NEETS_API_KEY=<your_neets_api_key>
   ```

5. **Run the Project**
   Execute the following command to start the server:
   ```bash
   sh start.sh
   ```

#### Using tmux (Recommended for Production)

 **Start a tmux session**:
   ```bash
   tmux new -s mysession
   ```

 **Run Uvicorn inside tmux**:
   ```bash
   cd cognito
   sh server.sh
   ```

 **Detach from tmux**:
   Press `Ctrl + B`, then `D`.

 **Reattach to tmux session**:
   ```bash
   tmux attach -t mysession
   ```

6. **Running the Mobile App**
   - Ensure Flutter is installed.
   - Connect a mobile device or emulator.
   - Navigate to the `app/cognito` directory and run:
     ```bash
     flutter run
     ```
7. ### Nginx Setup

 **Install Nginx**:
   ```bash
   sudo apt update
   sudo apt install nginx
   ```

 **Configure Nginx**:
   Edit `/etc/nginx/sites-available/default`:
   

   ```nginx
   server {
       listen 80;
       server_name cognito.fun www.cognito.fun;

       location / {
           proxy_pass http://127.0.0.1:3000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

 **Test and Reload Nginx**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   sudo ufw allow 'Nginx Full'

  sudo nano /etc/nginx/sites-available/cognito.fun

  sudo ln -s /etc/nginx/sites-available/cognito.fun /etc/nginx/sites-enabled/

   ```


### Redis Setup

1. **Install Redis**:
   ```bash
   sudo apt update
   sudo apt install redis-server
   ```

2. **Enable and Start Redis**:
   ```bash
   sudo systemctl enable redis-server
   sudo systemctl start redis-server
   ```

3. **Verify Redis Installation**:
   - Test the connection to Redis:
     ```bash
     redis-cli ping
     ```
   - You should receive a `PONG` response if Redis is running correctly.


### Monitoring and Managing Processes

- **Check running processes**:
  ```bash
  ps aux | grep uvicorn
  ```

- **Check listening ports**:
  ```bash
  sudo lsof -i :3000
  ```

- **Use top or htop for real-time monitoring**:
  ```bash
  top
  # or
  htop
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

This project is licensed under the AGPL 3.0 License - see the [LICENSE](LICENSE) file for details.

---
