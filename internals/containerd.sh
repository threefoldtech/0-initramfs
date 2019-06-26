CONTAINERD_REPOSITORY="https://github.com/containerd/containerd"
CONTAINERD_BRANCH="v1.2.7"
CONTAINERD_HOME="${GOPATH}/src/github.com/containerd"

download_containerd() {
    download_git ${CONTAINERD_REPOSITORY} ${CONTAINERD_BRANCH}
}

extract_containerd() {
    event "refreshing" "containerd-${CONTAINERD_BRANCH}"
    rm -rf ${CONTAINERD_HOME}/containerd
    cp -a ${DISTFILES}/containerd ${CONTAINERD_HOME}/

}

prepare_containerd() {
    echo "[+] prepare containerd"
}

compile_containerd() {
    echo "[+] compiling containerd"
    make CGO_CFLAGS=-I${ROOTDIR}/usr/include
}

install_containerd() {
    echo "[+] copying binaries"
    cp -av bin/* "${ROOTDIR}/usr/bin/"
}

build_containerd() {
    pushd ${CONTAINERD_HOME}/containerd

    prepare_containerd
    compile_containerd
    install_containerd

    popd
}


registrar_containerd() {
    DOWNLOADERS+=(download_containerd)
    EXTRACTORS+=(extract_containerd)
}

registrar_containerd

