RUNC_REPOSITORY="https://github.com/opencontainers/runc"
RUNC_BRANCH="master"

RUNC_TAG="v1.0.0-rc8"

download_runc() {
    DIR=$GOPATH/src/github.com/opencontainers
    mkdir -p $DIR
    pushd $DIR
    download_git $RUNC_REPOSITORY $RUNC_BRANCH $RUNC_TAG
    popd
}

prepare_runc() {
    echo "[+] prepare runc"
}

compile_runc() {
    echo "[+] compiling runc"
    pushd runc
    make BUILDTAGS='seccomp'
    popd
}

install_runc() {
    echo "[+] copying binaries"
    pushd runc
    cp -a bin/* "${ROOTDIR}/bin/"
}

build_runc() {
    mkdir -p $GOPATH/src/github.com/opencontainers
    pushd $GOPATH/src/github.com/opencontainers

    prepare_runc
    compile_runc
    install_runc

    popd
}


registrar_runc() {
    DOWNLOADERS+=(download_runc)
}

registrar_runc
