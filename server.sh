#!/bin/bash

# Install jq if it's not installed (only needed once)
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

# If you decide to use ngrok, start it in the background (optional)
# ngrok http 8000 &

# Wait for ngrok to start and retrieve the tunnel URL (Skip if using IP)
# sleep 5
# ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

# Use machine's IP instead of ngrok URL
ngrok_url="http://206.1.35.50:8000"  # Replace YOUR_MACHINE_IP with the actual IP

# Print the server URL
echo "Server URL: $ngrok_url"

# Update URL in Firestore database using Python
python3 - <<EOF
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Fetch the service account key JSON file from Firebase console and save it locally
cred = credentials.Certificate('firebaseKeys.json')

# Initialize the Firebase app
firebase_admin.initialize_app(cred)

# Get a reference to the Firestore database
db = firestore.client()

# Specify the collection and document ID
collection_name = 'ngrok_URLs'
document_id = "url"

# Update the URL in the document
doc_ref = db.collection(collection_name).document(document_id)
doc_ref.set({
    'url': "$ngrok_url"
})

print("URL updated successfully in Firestore database")
EOF

# Start the FastAPI server using uvicorn directly in the same terminal
cd apis
/home/ubuntu/.local/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2 --reload

: