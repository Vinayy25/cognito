#!/bin/bash

# Install jq if it's not installed (only needed once)
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
fi




# Navigate to the apis folder
cd apis

# Start the FastAPI server using uvicorn with 2 workers
uvicorn main:app --host 0.0.0.0 --port 3000 --workers 2 --reload 
