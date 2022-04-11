import os 
import binascii

size = 1
result = os.urandom(size)
      
# Print the random bytes string
# Output will be different everytime
print(result) 