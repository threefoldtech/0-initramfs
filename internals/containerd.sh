CONTAINERD_VERSION="v1.2.7"

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

prepare_containerd() {
    echo "[+] loading source code: containerd"
    github_force containerd/containerd $CONTAINERD_VERSION containerd
}

compile_containerd() {
    echo "[+] compiling coreX and core0"
    pushd containerd
    CGO_CFLAGS=-I${ROOTDIR}/usr/include make
    popd
}

install_containerd() {
    echo "[+] copying binaries"
    pushd containerd
    cp -a bin/* "${ROOTDIR}/bin/"
}

build_containerd() {
    mkdir -p $GOPATH/src/github.com/containerd
    pushd $GOPATH/src/github.com/containerd

    prepare_containerd
    compile_containerd
    install_containerd

    popd
}