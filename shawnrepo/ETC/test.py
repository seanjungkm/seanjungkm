import pickle
FLAG=['FLAG']
 
## Save pickle
with open("FLAG.pickle","wb") as fw:
    pickle.dump(FLAG, fw)

print(FLAG)