#!/bin/bash

mkdir -m 600 -p "${ROOTDIR}"/root/.ssh
rm -f "${ROOTDIR}"/root/.ssh/authorized_keys

if [ "${BUILDMODE}" = "debug" ]; then
    for user in "muhamadazmy delandtj maxux LeeSmet DylanVerstraete"; do
        echo "[+] authorizing ssh key: $user"
        wget https://github.com/${user}.keys -O- >> "${ROOTDIR}"/root/.ssh/authorized_keys
    done

    chmod -f 600 "${ROOTDIR}"/root/.ssh/authorized_keys
fi