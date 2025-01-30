#!/bin/bash
set -e

BUILDMODE="${BUILDMODE:-debug}"

cd staging

kernel=zero-os-${IMAGE_BRANCH}-${BUILDMODE}-${GITHUB_SHA:0:10}.efi
linkname=zero-os-${IMAGE_BRANCH}-${BUILDMODE}.efi

echo "[+] kernel: ${kernel}"
echo "[+] branch: ${linkname}"

cp vmlinuz.efi "${kernel}"

curl -b "token=${BOOTSTRAP_TOKEN}" -X POST -F "kernel=@${kernel}" "https://v4.bootstrap.grid.tf/api/kernel"
curl -b "token=${BOOTSTRAP_TOKEN}" "https://v4.bootstrap.grid.tf/api/symlink/${linkname}/${kernel}"
