MODULES_REPOSITORY="https://github.com/threefoldtech/zosv2"
MODULES_BRANCH="master"
MODULES_TAG=""

MODULES_SRC=$GOPATH/src/github.com/threefoldtech

download_modules() {
    mkdir -p $MODULES_SRC
    pushd $MODULES_SRC
    download_git $MODULES_REPOSITORY $MODULES_BRANCH $MODULES_TAG
    popd
}

prepare_modules() {
    echo "[+] prepare modules"
}

compile_modules() {
    echo "[+] compiling modules"
    pushd modules/cmds
    make
    popd
}

install_modules() {
    echo "[+] copying binaries"
    pushd modules
    cp -a bin/* "${ROOTDIR}/bin/"
    cp -a zinit/* "${ROOTDIR}/etc/zinit/"
    popd
}

build_modules() {
    pushd $MODULES_SRC

    prepare_modules
    compile_modules
    install_modules

    popd
}


registrar_modules() {
    DOWNLOADERS+=(download_modules)
}

registrar_modules
