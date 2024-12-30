import asyncio
import websockets
import json

async def test_websocket():
    uri = (
        "ws://localhost:8000/groq/chat-stream/ws?"
        "user=test_user&query=What%20is%smvitm&id=123&model_type=test_model"
        "&perform_rag=false&perform_web_search=false"
    )

    async with websockets.connect(uri) as websocket:
        try:
            while True:
                # Wait for messages from the server
                message = await websocket.recv()
                parsed_message = json.loads(message)
                if parsed_message.get("type") == "content":
                    print(f"Chunk: {parsed_message['data']}")
                else:
                    print(f"Other Message: {parsed_message}")

        except websockets.exceptions.ConnectionClosed:
            print("WebSocket connection closed")

asyncio.run(test_websocket())
