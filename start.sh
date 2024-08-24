#!/bin/bash




# Execute ngrok in a new terminal window
gnome-terminal -- ngrok http 8000

# Wait for ngrok to start and retrieve the tunnel URL
sleep 5
ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

# Print the ngrok URL
echo "Ngrok URL: $ngrok_url"

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


# Start the FastAPI server using uvicorn
cd apis
gnome-terminal -- uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2 --reload


