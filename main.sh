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

decrypted_output=$(echo "$encrypted_b64" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$password" -pbkdf2 -iter 16988354 2>&1)
decryption_status=$?

echo "$decrypted_output" | grep -q "bad decrypt"
if [[ $decryption_status -ne 0 || $? -eq 0 ]]; then
  echo "Decryption failed: Incorrect password or corrupted data."
  exit 1
fi

echo "Decryption successful. Decrypted content:"
echo "$decrypted_output"
