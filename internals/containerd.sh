CONTAINERD_REPOSITORY="https://github.com/containerd/containerd"
CONTAINERD_BRANCH="master"

CONTAINERD_TAG="v1.2.7"

download_containerd() {
    DIR=$GOPATH/src/github.com/containerd
    mkdir -p $DIR
    pushd $DIR
    download_git $CONTAINERD_REPOSITORY $CONTAINERD_BRANCH $CONTAINERD_TAG
    popd
}

prepare_containerd() {
    echo "[+] prepare containerd"
}

compile_containerd() {
    echo "[+] compiling containerd"
    pushd containerd
    make CGO_CFLAGS=-I${ROOTDIR}/usr/include
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


registrar_containerd() {
    DOWNLOADERS+=(download_containerd)
}

registrar_containerd
