_machine_id = c31eea55a29431535ff01de94bdcf5cf
 
 
def get_machine_id():
    global _machine_id
 
    if _machine_id is not None:
        return _machine_id
 
    def _generate():
        linux = b"c31eea55a29431535ff01de94bdcf5cflibpod-89adcf650a0a154baaafa9b35e4555914066838e61c7375de6a10500e35b7672"
 
        # machine-id is stable across boots, boot_id is not.
        for filename in "/etc/machine-id", "/proc/sys/kernel/random/boot_id":
            try:
                with open(filename, "rb") as f:
                    value = f.readline().strip()
            except IOError:
                continue
 
            if value:
                linux += value
                break
 
        # Containers share the same machine id, add some cgroup
        # information. This is used outside containers too but should be
        # relatively stable across boots.
        try:
            with open("/proc/self/cgroup", "rb") as f:
                linux += f.readline().strip().rpartition(b"/")[2]
        except IOError:
            pass
 
        if linux:
            return linux
 
 
    _machine_id = _generate()
    return _machine_id