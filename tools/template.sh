#!/bin/bash

if [ "$2" == "" ]; then
    echo "Missing arguments: $0 <name> <url>"
    exit 1
fi

name="$1"
url="$2"
lowname="${name,,}"
upname="${name^^}"
tempfile="/tmp/template.temp"

echo "[+] name: ${name}" >&2
echo "[+] lowercase: ${lowname}" >&2
echo "[+] uppercase: ${upname}" >&2
echo "[+] url: ${url}" >&2

echo "[+] downloading archive..." >&2
wget -q -O "${tempfile}" "${url}"

checksum=$(md5sum "${tempfile}" | awk '{ print $1 }')
echo "[+] md5sum: ${checksum}" >&2

sed "s/##upname##/${upname}/g;s/##lowname##/${lowname}/g;s/##checksum##/${checksum}/g;s*##link##*${url}*g" build.template

rm -f "${tempfile}"
