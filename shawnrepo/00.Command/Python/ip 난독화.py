try:
    import re
except ImportError as e:
    print('[!] Import Error : %s' % e)

class IpOpfuscator:

    def isValid(self, ip):
        ip_pattern = '((0|1[0-9]{0,2}|2[0-9]?|2[0-4][0-9]|25[0-5]|[3-9][0-9]?)\.){3}(0|1[0-9]{0,2}|2[0-9]?|2[0-4][0-9]|25[0-5]|[3-9][0-9]?)'
        match = re.match(ip_pattern, ip)
        if match is not None:
            return True
        return False

    def opfuscate(self, ip):
        octets = ['%02x' % int(octet) for octet in ip.split('.')]
        return '%d' % int(''.join(octets), 16)


def main():
    io = IpOpfuscator()
    while True:
        ip = input('Enter Ip address : ')
        if io.isValid(ip):
            print('http://%s' % io.opfuscate(ip))
        else:
            print('Invalid ip value')


if __name__ == '__main__':
    main()