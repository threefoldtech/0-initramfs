CONTAINERD_VERSION="1.3.2"
CONTAINERD_CHECKSUM="d28ec96dd7586f7a1763c54c5448921e"
CONTAINERD_LINK="https://github.com/containerd/containerd/archive/v${CONTAINERD_VERSION}.tar.gz"
CONTAINERD_HOME="${GOPATH}/src/github.com/containerd"

download_containerd() {
    download_file ${CONTAINERD_LINK} ${CONTAINERD_CHECKSUM} containerd-v${CONTAINERD_VERSION}.tar.gz
}

extract_containerd() {
    # event "refreshing" "containerd-${CONTAINERD_BRANCH}"
    mkdir -p ${CONTAINERD_HOME}
    rm -rf ${CONTAINERD_HOME}/containerd
    # cp -a ${DISTFILES}/containerd ${CONTAINERD_HOME}/

    pushd ${CONTAINERD_HOME}

    echo "[+] extracting: containerd-${CONTAINERD_VERSION}"
    tar -xf ${DISTFILES}/containerd-v${CONTAINERD_VERSION}.tar.gz -C .
    mv containerd-${CONTAINERD_VERSION} containerd

    popd

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

