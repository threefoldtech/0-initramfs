RUNC_VERSION="v1.0.0-rc8"

github_force() {
    if [ -d $3 ]; then
        pushd $3
        git fetch
        git checkout $2
        git pull origin $2
        popd

    else
        git clone https://github.com/$1 $3
        pushd $3
        git checkout $2
        popd
    fi
}

prepare_runc() {
    echo "[+] loading source code: runc"
    github_force opencontainers/runc $RUNC_VERSION runc
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
    cp runc "${ROOTDIR}/bin/"
}

build_runc() {
    mkdir -p $GOPATH/src/github.com/opencontainers
    pushd $GOPATH/src/github.com/opencontainers

    prepare_runc
    compile_runc
    install_runc

    popd
}
