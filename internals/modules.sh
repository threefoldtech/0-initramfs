MODULES_REPOSITORY="https://github.com/threefoldtech/zosv2"
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

compile_modules() {
    echo "[+] compiling modules"
    pushd cmds
    make GO111MODULE=on _base
    popd
}

install_modules() {
    echo "[+] copying binaries"
    mkdir -p "${ROOTDIR}/bin/" "${ROOTDIR}/etc/zinit/"
    
    cp -a bin/* "${ROOTDIR}/bin/"
    cp -a zinit/* "${ROOTDIR}/etc/zinit/"
}

build_modules() {
    pushd $TFT_SRC/zosv2

    prepare_modules
    compile_modules
    install_modules

    popd
}


registrar_modules() {
    DOWNLOADERS+=(download_modules)
}

registrar_modules
