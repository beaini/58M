#!/bin/bash

# Hardcoded encrypted Base64 text
encrypted_b64="U2FsdGVkX18d0htDNKzZASXoXwpLKh8prDcJUBpBX1yax9ZM84THsPw3JBIhcORp
HJxl65NFukQOvh07MUFzmNDdaGJAuSgoR4syr1eDhyVhTrqIcNL6B75zKauhXEKv
IatZKCXiV/I48klDegqzzzxisGJqr4SB1w7qJQ27VZzn6EMtAJN/QrkvL1sFXIzU
OggGH9iFYuI0iMvCC85OLKz4hyaKJGRBOhbq+qOc+EUOwnmZL7501W+5VZqGY6M7
eE+kwsPRv2Wm67rUsmltVzYcjTzx5k75+df6PMFs4U7wQW9kGgrM/koGJuu2cPGm
DOiM5tRpP2SuchrZVaJOsMRoMeENqXQ6M+RV9k4Mg23fwSwxNMBX+Z6PkIH3Mwh0
MRrIP2sD83X09jX4Q2/FYJGPplPxSAvjK4HgpfDy+SpNAN3KidwOjhVy3np1nZ/T
7K529SNkizw6vo12+eDBt/rJneq02lWeta85X1ZFlG+yjbWNHF6w1sqjDNOUErsW
nkzCGceLxd8oT7Ro6Ch9wxwz2a7NrYJrBN3Gf2evsIkvUUj5LR30dgeyr5Ys0viY
tfY16x2NAR6OlGoT0tB7K3Nz9DgxdurLa1Vbx6aLgDMxLQsuC3x5e6FUIwKubXcd
z0mMZXnK1G0+sqGm4jBE3Ag+4CCbDunu/Wwc9SVKDHyh2P44SlvbulC0/acqLhqx
Us0R7MED3qXRm/wpDlE2u579swSkymDBcL7sOZ1zBx96OxtxO0Vq/f4CvzILdhik
uATdN+7qUWawi/jXn5Z6zOhpQGkzX2djRg9j8BBpA8Wk6nlhdkg8AzqQW18d3PJn
39XVQbp5VdYIvx1MPpRjM/97E3zn12k9bpWSMumemkmhRsW94Vs0MKDoPFZAKjMN
W/QaJyMi/q2mjABSkWBuHgKH+/qdfVlqUoIacvrVEMlnH0rrP6fSEHWl4SkYloxU
9jyhFEVJTFezJnB8PtVOftBjEf/GTfL59FPQH9J/BikP9hplN1/HiPaLWdIerwWe
2kuZPSJFe/d2TwCClRHMjMjOrN+obO1O7uPLnm+uVJ3HC+xLlq6WbbhBwb/wgB5d
0kWQxBNxCQ55Af6o8xeV9A=="

# Check OpenSSL version compatibility
openssl_version=$(openssl version)
if [[ ! "$openssl_version" =~ "OpenSSL" ]]; then
  echo "Error: OpenSSL not found or incompatible version."
  exit 1
fi

# Prompt for the decryption password
echo -n "Enter decryption password: "
read -s password
echo

decrypted_output=$(echo "$encrypted_b64" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$password" -pbkdf2 -iter 10000000 2>&1)
decryption_status=$?

echo "$decrypted_output" | grep -q "bad decrypt"
if [[ $decryption_status -ne 0 || $? -eq 0 ]]; then
  echo "Decryption failed: Incorrect password or corrupted data."
  exit 1
fi

echo "Decryption successful. Decrypted content:"
echo "$decrypted_output"
