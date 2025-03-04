MODULES_BASE_REPOSITORY="https://github.com/threefoldtech/zoslight"
MODULES_BASE_VERSION="main"

MODULES_BOOTSTRAP_REPOSITORY="https://github.com/threefoldtech/zos"
MODULES_BOOTSTRAP_VERSION="main"

download_modules() {
    download_git ${MODULES_BASE_REPOSITORY} ${MODULES_BASE_VERSION}
    download_git ${MODULES_BOOTSTRAP_REPOSITORY} ${MODULES_BOOTSTRAP_VERSION}
}

extract_modules() {
    event "refreshing" "zos-${MODULES_BASE_VERSION}"
    rm -rf ./zos-${MODULES_BASE_VERSION}
    cp -a ${DISTFILES}/zoslight ./zos-base-${MODULES_BASE_VERSION}

    event "refreshing" "zos-bootstrap-${MODULES_BOOTSTRAP_VERSION}"
    rm -rf ./zos-bootstrap-${MODULES_BOOTSTRAP_VERSION}
    cp -a ${DISTFILES}/zos ./zos-bootstrap-${MODULES_BOOTSTRAP_VERSION}

    event "merging" "zos-bootstrap-${MODULES_BOOTSTRAP_VERSION} > zos-base-${MODULES_BASE_VERSION}"
    rm -rf ./zos-base-${MODULES_BASE_VERSION}/boostrap
    cp -a ./zos-bootstrap-${MODULES_BOOTSTRAP_VERSION}/bootstrap ./zos-base-${MODULES_BASE_VERSION}/
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
    pushd ${WORKDIR}/zos-base-${MODULES_BASE_VERSION}

    prepare_modules
    install_modules

    popd
}

registrar_modules() {
    DOWNLOADERS+=(download_modules)
    EXTRACTORS+=(extract_modules)
}

registrar_modules
