KEYUTILS_VERSION="1.6.3"
KEYUTILS_CHECKSUM="6b70b2b381c1b6d9adfaf66d5d3e7c00"
KEYUTILS_LINK="https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git/snapshot/keyutils-${KEYUTILS_VERSION}.tar.gz"

download_keyutils() {
    download_file $KEYUTILS_LINK $KEYUTILS_CHECKSUM
}

extract_keyutils() {
    if [ ! -d "keyutils-${KEYUTILS_VERSION}" ]; then
        echo "[+] extracting: keyutils-${KEYUTILS_VERSION}"
        tar -xf ${DISTFILES}/keyutils-${KEYUTILS_VERSION}.tar.gz -C .
    fi
}

compile_keyutils() {
    make ${MAKEOPTS}
}

install_keyutils() {
    make LIBDIR=/usr/lib install
}

build_keyutils() {
    pushd "${WORKDIR}/keyutils-${KEYUTILS_VERSION}"

    compile_keyutils
    install_keyutils

    popd
}

registrar_keyutils() {
    DOWNLOADERS+=(download_keyutils)
    EXTRACTORS+=(extract_keyutils)
}

registrar_keyutils
