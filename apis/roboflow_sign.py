from inference_sdk import InferenceHTTPClient

CLIENT = InferenceHTTPClient(
    api_url="https://detect.roboflow.com",
    api_key="BOckT9t0CiNowlaex4eM"
)

result = CLIENT.infer("img1.png", model_id="sign-language-recognition-mmbok/1")

print(result)