#!/usr/bin/env python3
import json
import os
import sys
import urllib.parse
import urllib.request
from pathlib import Path


def load_env():
    """Load .env file from hooks directory"""
    env_path = Path(__file__).parent / ".env"
    if env_path.exists():
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    os.environ[key] = value


def send_pushover_notification():
    """Send a fixed-content notification via Pushover API.

    The payload contains no conversation content — only a fixed string,
    title, device, and priority. This avoids exfiltrating any secrets or
    PII that may appear in Claude's reply text to a third-party service.
    """
    api_token = os.environ.get("PUSHOVER_APP_TOKEN")
    user_key = os.environ.get("PUSHOVER_USER_KEY")

    if not api_token or not user_key:
        print("Warning: PUSHOVER_APP_TOKEN or PUSHOVER_USER_KEY not set", file=sys.stderr)
        return False

    data = urllib.parse.urlencode({
        "token": api_token,
        "user": user_key,
        "message": "Claude Code task finished",
        "title": "Claude Code Task Finished",
        "device": "iphone15",
        "priority": -1
    }).encode()

    try:
        req = urllib.request.Request("https://api.pushover.net/1/messages.json", data=data)
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode())
            return result.get("status") == 1
    except Exception as e:
        print(f"Error sending notification: {e}", file=sys.stderr)
        return False

def main():
    load_env()

    event = json.load(sys.stdin)

    if event.get("type") == "message" and event.get("role") == "assistant":
        send_pushover_notification()

    json.dump(event, sys.stdout)

if __name__ == "__main__":
    main()