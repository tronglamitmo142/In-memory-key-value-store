#!/bin/bash

# Take key-pair name as input 
read -p "Name of key pair: " key_pair_name

# Add the .pem extension 
key_pair_name="${key_pair_name}"

# Generate the SSH key pair 
ssh-keygen -t rsa -b 4096 -m pem -f "${key_pair_name}"

# Set the appropriate permissions for the private key 
chmod 400 "${key_pair_name}"

echo "SSH key pair '${key_pair_name}' and '${key_pair_name}.pub' created successfully."

