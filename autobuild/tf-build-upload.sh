#!/bin/bash
set -e

cd staging

kernel=zero-os-${IMAGE_BRANCH}-generic-${GITHUB_SHA:0:10}.efi
linkname=zero-os-${IMAGE_BRANCH}-generic.efi

echo "[+] kernel: ${kernel}"
echo "[+] branch: ${linkname}"

cp vmlinuz.efi "${kernel}"

curl -b "token=${BOOTSTRAP_TOKEN}" -X POST -F "kernel=@${kernel}" "https://bootstrap.grid.tf/api/kernel"
curl -b "token=${BOOTSTRAP_TOKEN}" "https://bootstrap.grid.tf/api/symlink/${linkname}/${kernel}"
