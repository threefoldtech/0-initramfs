#!/bin/bash
set -e

if [ -z "$2" ]; then
    echo "Usage: $0 <binary> <root target>"
    echo ""
    echo "Exemple: "
    echo "  $0 /newroot/bin/cp /tmp/newroot/"

    exit 1
fi

sourcebin="$1"
rootpath="$2"

#
# internal helpers
#
pushd() {
    command pushd "$@" > /dev/null
}

popd() {
    command popd "$@" > /dev/null
}

#
# this helper will takes resolv libs which are
# not directly linked to binaries but needed for dns resolution
# and other names resolving
#
resolv_libs() {
    paths=$(grep -hr ^/ /etc/ld.so.conf*)
    for path in $paths; do
        if [ ! -e "$path/libresolv.so.2" ]; then
            continue
        fi

        echo "[+] copying libresolv dependencies"
        cp -aL $path/libresolv* "${rootpath}/lib/"
        cp -a $path/libnss_{compat,dns,files}* "${rootpath}/lib/"
        cp -a $path/libnsl* "${rootpath}/lib/"
        return
    done

    echo "[-] warning: no libs found for resolving names"
    echo "[-] you probably won't be able to do dns request"
}

ensure_libs() {
    pushd "${rootpath}"

    echo "[+] checking ${sourcebin} dependencies"

    if [ ! -e lib64 ]; then mkdir lib64; fi
    if [ ! -e lib ]; then ln -s lib64 lib; fi

    # Copiyng ld-dependancy
    ld=$(ldd $sourcebin | grep ld-linux | awk '{ print $1 }')
    cp -aL $ld lib/

    # Copying resolv libraries
    resolv_libs

    libs=$(ldd $sourcebin 2>&1 | grep '=>' | grep 'not found' | awk '{ print $1 }' || true)
    for lib in $libs; do
        echo "[-] warning: $lib: not found"
    done

    # Looking for dynamic libraries shared
    libs=$(ldd $sourcebin 2>&1 | grep '=>' | grep -v '=>  (' | awk '{ print $3 }' || true)

    # Checking each libraries
    for lib in $libs; do
        libname=$(basename $lib)

        # Library found and not the already installed one
        if [ -e lib/$libname ] || [ "$lib" == "${PWD}/lib/$libname" ]; then
            continue
        fi

        if [ "$libname" == "not" ]; then
            continue
        fi

        # Grabbing library from host
        echo "[+] copying $libname"
        cp -aL $lib lib/
    done

    popd
}

ensure_libs
