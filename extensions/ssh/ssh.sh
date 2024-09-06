#!/bin/bash

mkdir -m 700 -p "${ROOTDIR}/root/.ssh"
rm -f "${ROOTDIR}/root/.ssh/authorized_keys"

if [ "${BUILDMODE}" == "debug" ]; then
    for user in muhamadazmy delandtj maxux LeeSmet coesensbert; do
        echo "[+] authorizing ssh key: ${user}"

        key=$(curl -s https://github.com/${user}.keys | tail -1)
        echo "${key} ${user}@initramfs" >> "${ROOTDIR}/root/.ssh/authorized_keys"
    done

    chmod -f 600 "${ROOTDIR}/root/.ssh/authorized_keys"
fi
