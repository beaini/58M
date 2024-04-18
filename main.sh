#!/bin/bash

# Hardcoded encrypted Base64 text
encrypted_b64="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
"

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

decrypted_output=$(echo "$encrypted_b64" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$password" -pbkdf2 -iter 10000000 2>&1)
decryption_status=$?

echo "$decrypted_output" | grep -q "bad decrypt"
if [[ $decryption_status -ne 0 || $? -eq 0 ]]; then
  echo "Decryption failed: Incorrect password or corrupted data."
  exit 1
fi

echo "Decryption successful. Decrypted content:"
echo "$decrypted_output"
