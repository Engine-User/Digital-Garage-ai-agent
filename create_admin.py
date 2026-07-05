# Digital Garage@2026
"""Run from the DIGITAL_GARAGE project root to create/reset admin user."""
import json
import os
import sys
import time

import bcrypt

AUTH_PATH = os.path.join("data", "auth.json")

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

os.makedirs("data", exist_ok=True)

config = {}
if os.path.exists(AUTH_PATH):
    with open(AUTH_PATH) as f:
        config = json.load(f)

if "users" not in config:
    config["users"] = {}

config["users"]["admin"] = {
    "password_hash": hash_password("admin"),
    "created": time.time(),
    "is_admin": True,
    "privileges": {
        "can_manage_users": True,
        "can_manage_settings": True,
        "can_manage_integrations": True,
    },
}

with open(AUTH_PATH, "w") as f:
    json.dump(config, f, indent=2)

print(f"Done. Login with  username=admin  password=admin")