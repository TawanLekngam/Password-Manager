#!/bin/bash

password_file="./.passwords"

if [ ! -f "$password_file" ]; then
    touch "$password_file"
fi

while true; do
    echo "Choose an operation:"
    echo "[1] Add New Password"
    echo "[2] Remove Password"
    echo "[3] Show Password"
    echo "[0] Exit"
    read operation

    case $operation in
        1)
            echo "Enter a new password:"
            read -s password
            echo "Enter the website or account name:"
            read account_name
            encrypted_password=$(echo "$password" | openssl enc -aes-256-cbc -a -pbkdf2)
            echo "$account_name:$encrypted_password" >> "$password_file"
            echo "Password added for $account_name."
            ;;
        2)
            echo "Enter the website or account name:"
            read account_name
            if grep -q "^$account_name:" "$password_file"; then
                sed -i "/^$account_name:/d" "$password_file"
                echo "Password removed for $account_name."
            else
                echo "Password not found for $account_name."
            fi
            ;;
        3)
            echo "Enter the website or account name:"
            read account_name
            if grep -q "^$account_name:" "$password_file"; then
                encrypted_password=$(grep "^$account_name:" "$password_file" | cut -d':' -f2)
                password=$(echo "$encrypted_password" | openssl enc -aes-256-cbc -a -d -pbkdf2)
                echo "Password for $account_name is: $password"
            else
                echo "Password not found for $account_name."
            fi
            ;;
        0)
            break
            ;;
        *)
            echo "Invalid operation. Please try again."
            ;;
    esac
done
