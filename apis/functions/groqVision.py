from groq import Groq
import os
import dotenv

import base64
dotenv.load_dotenv()

client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def analyze_image(image_path):
    # Encode the image to base64
    base64_image = encode_image(image_path)

    # Create a chat completion request
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "What's in this image?"},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{base64_image}",
                        },
                    },
                ],
            }
        ],
        model="llama-3.2-11b-vision-preview",
    )

    # Return the response content
    return chat_completion.choices[0].message.content

# Example usage
# response = analyze_image("sf.jpg", client)
# print(response)


