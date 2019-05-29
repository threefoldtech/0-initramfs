#!/bin/ash
if [ -f /etc/ssh/ssh_host_rsa_key ]; then
    # nothing to do, hackish way
    sleep 10
    exit 0
fi

echo "Setting up sshd"
mkdir -p /run/sshd

ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
