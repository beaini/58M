#!/bin/bash

# Hardcoded encrypted Base64 text
encrypted_b64="U2FsdGVkX1/8IjniU/TVoG2W3w30VJzF2smJKW/kswfws0AwxRzeLD9lZSnXVZBN
m7IF06IraZwlggg4TRlhkFTHNnScLW8J3vov9ORsoQvEk669S7YsBmZamUoM5jKa
UqryzBQvL9Ug04Aih57HgQW5EBaGSrRp70H/zy+DgqzdwDsAzRlEboo6TmzThbLh
vfVYNIjbNFTN6bOQovjTcbD+lwAwTUqYna8iFXlSMaWIKanRav4Tep5NXSDCCDyO
qigOaR9DE3L8WRD39au+MCWpyL0+lhS5EpYoGE7jRTN41kV6iAQ4dBw+RPGtipvG
Djt95QxwkC+pVBNPcKKlLsZuL031ty3RgRmy3k5ujogbg6guUfH3sknpEoLjwBg3
asFApWUWx0iNK0Wpz409cLXM2pxIZmf25C+1nABG4rM63iCxmIckzLutEW2nraPk
XJALHhnSN6p/dUXzrkT5/JOFSDnLjuuHYPru/aNmPHCgZtVKDpgw7tXJsKOHUsaL
JPf+3exawgLjSNmZsbBNWsBQXGPLCgXYWDWYyfxJrnr89jpozYessr0r+d4IsJ0b
DKMRDc8YjghIX2gC28k/81XKLZJPLpKuHas5nFUZh4YLa6H6xvnWL3Du59wmvL3d
qkgAYOD0Gzvb83xL0t50YVCz+JUGPs+29uNI19tU/U5nwGI0aS1YcQOK7GDomJqh
EQbC6APF+4aW3jbYK1oVWFzQvQMxozOyZZmzp6eCW19UBZ7fLZqQNaYW2b3VB3cs
bG+nPYedqIypuMr2oe/CAog8Kosk8ARbTOklk4X5EhgrJZIhM16SmVVsJBXtQr+5
XizWudtVVLc+BM3P2yPNIiVRGrVN2hIcymtlMhI7BMsoFBpV1XXHrjlb7Di3bkHY
k/4jYDKY5nnESiXpwkK0/OjGIJuu/pEEvU1nU0DU8SopwBdPr021F3dzoOIIV3dL
Yck5hiDm9t2bmSKxt3/2KHjZQTx9evCV7X1i2zWhg7J6SGdsUzOJmVJIDvHU1P1s
3tQA5IP7f2Sr0YgEbftQW+Db+x7YqioBeJS+IoXRkD0996OY2h8Wb4pb3mv2z0rl
A5Zb9P8aTT2KvFmPONrdwaVB7tBf9nIkTa2YaEZ4SsIiXl0jnlDCYoA93c2y4a+X
GG1MJAILggAXSiQaI5NF7uyklftQEOmEfrbTX6YORUpimKE9kCLzBvPaTRRi0Qeh
wjsQftTm3b/AYdSjtQ3grMpqauHzY2ZrNNgAxspM0PkD6OYsXmvbaSjvjC2wnM76
ZDMMWIBofgO7pwUJQT0A0X2Eks7ng05UdF3SfOA9kbVfcztjcW4D6QJ9hNaOlXHD
33Sm+iDJRp2nLwqL22lJFw=="

# Check OpenSSL version compatibility
openssl_version=$(openssl version)
if [[ ! "$openssl_version" =~ "OpenSSL" ]]; then
  echo "Error: OpenSSL not found or incompatible version."
  exit 1
fi

# Check if a password was provided as a command-line argument
if [ -z "$1" ]; then
  echo -n "Enter decryption password: "
  read -s password
  echo
else
  password="$1"
fi

decrypted_output=$(echo "$encrypted_b64" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$password" -pbkdf2 -iter 16988354 2>&1)
decryption_status=$?

echo "$decrypted_output" | grep -q "bad decrypt"
if [[ $decryption_status -ne 0 || $? -eq 0 ]]; then
  echo "Decryption failed: Incorrect password or corrupted data."
  exit 1
fi

echo "Decryption successful. Decrypted content:"
echo "$decrypted_output"
