#!/bin/bash

# Check OpenSSL version compatibility
openssl_version=$(openssl version)
if [[ ! "$openssl_version" =~ "OpenSSL" ]]; then
  echo "Error: OpenSSL not found or incompatible version."
  exit 1
fi

# Check if a password was provided as a command-line argument
if [ -z "$1" ]; then
  echo -n "Enter encryption password: "
  read -s password
  echo
else
  password="$1"
fi

# Prompt user for the file path
echo -n "Enter the path to the file you wish to encrypt: "
read file_path

# Check if the file exists
if [ ! -f "$file_path" ]; then
  echo "Error: File does not exist."
  exit 1
fi

# Encrypt the file content and output the result in base64
encrypted_output=$(openssl enc -aes-256-cbc -e -a -salt -in "$file_path" -pass pass:"$password" -pbkdf2 -iter 16988354 2>&1)
encryption_status=$?

# Check if encryption was successful
if [ $encryption_status -ne 0 ]; then
  echo "Encryption failed."
  exit 1
fi

echo "Encryption successful. Encrypted content (base64):"
echo "$encrypted_output"
