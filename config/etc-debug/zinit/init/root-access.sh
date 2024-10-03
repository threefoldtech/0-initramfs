#!/bin/ash

passgen=$(dd if=/dev/random bs=1024 count=1 | base64 | tr -cd [:alnum:] | head -c 24)

echo "root:${passgen}" | chpasswd

echo "This is a development node running in debug mode" > /etc/issue.net
echo "Session credential: ${passgen}" >> /etc/issue.net
echo >> /etc/issue.net
