MODULES_VERSION="0.4.3"
MODULES_CHECKSUM="99fd8573891897543db73673b6f2016d"
MODULES_LINK="https://github.com/threefoldtech/zos/archive/v${MODULES_VERSION}.tar.gz"

download_modules() {
    download_file $MODULES_LINK $MODULES_CHECKSUM zos-${MODULES_VERSION}.tar.gz
}

extract_modules() {
    if [ ! -d "zos-${MODULES_VERSION}" ]; then
        echo "[+] extracting: zos-${MODULES_VERSION}"
        tar -xf ${DISTFILES}/zos-${MODULES_VERSION}.tar.gz -C .
    fi
}

prepare_modules() {
    echo "[+] prepare modules"
}

install_modules() {
    echo "[+] building zos bootstrap"
    pushd bootstrap
    make install GO111MODULE=on ROOT=${ROOTDIR}
    popd
}

build_modules() {
    pushd ${WORKDIR}/zos-${MODULES_VERSION}

    prepare_modules
    install_modules

    popd
}

registrar_modules() {
    DOWNLOADERS+=(download_modules)
    EXTRACTORS+=(extract_modules)
}

registrar_modules
