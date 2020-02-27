MODULES_REPOSITORY="https://github.com/threefoldtech/zos"
MODULES_BRANCH="master"
MODULES_TAG=""

TFT_SRC=$GOPATH/src/github.com/threefoldtech

download_modules() {
    mkdir -p $TFT_SRC
    pushd $TFT_SRC
    download_git $MODULES_REPOSITORY $MODULES_BRANCH $MODULES_TAG
    popd
}

prepare_modules() {
    echo "[+] prepare modules"
}

install_modules() {
    echo "[+] copying binaries"
    pushd bootstrap
    make install GO111MODULE=on ROOT=${ROOTDIR}
    popd
}

build_modules() {
    pushd $TFT_SRC/zosv2

    prepare_modules
    install_modules

    popd
}

registrar_modules() {
    DOWNLOADERS+=(download_modules)
}

registrar_modules
