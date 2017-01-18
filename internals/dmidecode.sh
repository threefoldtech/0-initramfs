DMIDECODE_VERSION="3.0"
DMIDECODE_CHECKSUM="281ee572d45c78eca73a14834c495ffd"
DMIDECODE_LINK="http://download.savannah.gnu.org/releases/dmidecode/dmidecode-${DMIDECODE_VERSION}.tar.xz"

download_dmidecode() {
    download_file $DMIDECODE_LINK $DMIDECODE_CHECKSUM
}

extract_dmidecode() {
    if [ ! -d "dmidecode-${DMIDECODE_VERSION}" ]; then
        echo "[+] extracting: dmidecode-${DMIDECODE_VERSION}"
        tar -xf ${DISTFILES}/dmidecode-${DMIDECODE_VERSION}.tar.xz -C .
    fi
}

prepare_dmidecode() {
    echo "[+] preparing dmidecode"
}

compile_dmidecode() {
    echo "[+] compiling dmidecode"
    make ${MAKEOPTS}
}

install_dmidecode() {
    echo "[+] installing dmidecode"
    cp -av dmidecode "${ROOTDIR}"/usr/bin/
}

build_dmidecode() {
    pushd "${WORKDIR}/dmidecode-${DMIDECODE_VERSION}"

    prepare_dmidecode
    compile_dmidecode
    install_dmidecode

    popd
}

