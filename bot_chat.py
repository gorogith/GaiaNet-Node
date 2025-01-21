#!/usr/bin/env python3
import requests
import time
import sys
from typing import List

def read_keywords(file_path: str) -> List[str]:
    """Read keywords from file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return [line.strip() for line in f if line.strip()]
    except Exception as e:
        print(f"Error reading keywords file: {e}")
        return []

def send_chat(message: str, node_id: str) -> None:
    """Send chat message to Gaia AI."""
    try:
        url = f"https://{node_id}.us.gaianet.network/v1/chat/completions"
        payload = {
            "messages": [
                {
                    "role": "system",
                    "content": "You are a helpful assistant."
                },
                {
                    "role": "user",
                    "content": message
                }
            ]
        }
        headers = {
            "accept": "application/json",
            "Content-Type": "application/json"
        }

        response = requests.post(url, json=payload, headers=headers)
        if response.status_code == 200:
            result = response.json()
            print(f"\n[Chat] Message: {message}")
            print(f"[Response] {result['choices'][0]['message']['content']}\n")
        else:
            print(f"Error: Status code {response.status_code}")
            print(f"Response: {response.text}\n")

    except Exception as e:
        print(f"Error sending chat: {e}\n")

def auto_chat(node_id: str, keyword_file: str = "keyword.txt", start_index: int = 11, delay: int = 30):
    """Main function to run auto chat."""
    print(f"\n=== Starting Auto Chat for Node {node_id} ===\n")
    
    keywords = read_keywords(keyword_file)
    if not keywords:
        print("No keywords found. Exiting...")
        return

    try:
        for i, keyword in enumerate(keywords[start_index:], start=start_index):
            print(f"Processing message {i+1}/{len(keywords)}")
            send_chat(keyword, node_id)
            time.sleep(delay)

    except KeyboardInterrupt:
        print("\nAuto chat stopped by user.")
    except Exception as e:
        print(f"Unexpected error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python gaian_chat.py <node_id>")
        sys.exit(1)
    
    node_id = sys.argv[1]
    auto_chat(node_id)
