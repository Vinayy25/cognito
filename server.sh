#!/bin/bash

# Install jq if it's not installed (only needed once)
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

# Use machine's IP instead of ngrok URL
server_url="http://206.1.35.50:8000"  # Replace YOUR_MACHINE_IP with the actual IP

# Print the server URL
echo "Server URL: $server_url"



# Navigate to the apis folder
cd apis

# Start the FastAPI server using uvicorn with 2 workers
uvicorn main:app --host 0.0.0.0 --port 3000 --workers 2 --reload 
