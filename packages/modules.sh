MODULES_REPOSITORY="https://github.com/threefoldtech/zos4"
MODULES_VERSION="main"

download_modules() {
    # download_file $MODULES_LINK $MODULES_CHECKSUM zos-${MODULES_VERSION}.tar.gz
    download_git ${MODULES_REPOSITORY} ${MODULES_VERSION}
}

extract_modules() {
    # if [ ! -d "zos-${MODULES_VERSION}" ]; then
    #     echo "[+] extracting: zos-${MODULES_VERSION}"
    #     tar -xf ${DISTFILES}/zos-${MODULES_VERSION}.tar.gz -C .
    # fi
    event "refreshing" "zos4-${MODULES_VERSION}"
    rm -rf ./zos4-${MODULES_VERSION}
    cp -a ${DISTFILES}/zos4 ./zos4-${MODULES_VERSION}
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
    pushd ${WORKDIR}/zos4-${MODULES_VERSION}

    prepare_modules
    install_modules

    popd
}

registrar_modules() {
    DOWNLOADERS+=(download_modules)
    EXTRACTORS+=(extract_modules)
}

registrar_modules
