#!/bin/bash

echo "ROOT: ${ROOTDIR}"
mkdir -m 700 -p "${ROOTDIR}"/root/.ssh
rm -f "${ROOTDIR}"/root/.ssh/authorized_keys

if [ "${BUILDMODE}" = "debug" ]; then
    for user in muhamadazmy delandtj maxux LeeSmet DylanVerstraete coesensbert; do
        echo "[+] authorizing ssh key: $user"
        wget https://github.com/${user}.keys -O- >> "${ROOTDIR}"/root/.ssh/authorized_keys
    done

    chmod -f 600 "${ROOTDIR}"/root/.ssh/authorized_keys
fi
