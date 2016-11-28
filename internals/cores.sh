CORES_VERSION="master"

prepare_cores() {
    echo "[+] loading source code: g8os coreX"
    go get -d -v github.com/g8os/coreX

    echo "[+] loading source code: g8os core0"
    go get -d -v github.com/g8os/core0
}

compile_cores() {
    echo "[+] compiling coreX"
    pushd coreX
    go build -ldflags "-s -w"
    popd

    echo "[+] compiling core0"
    pushd core0
    go build -ldflags "-s -w"
    popd
}

install_cores() {
    echo "[+] copying binaries"
    cp -av coreX/coreX core0/core0 "${ROOTDIR}/sbin/"
}

build_cores() {
    # We need to prepare first (download code)
    prepare_cores
    pushd $GOPATH/src/github.com/g8os

    compile_cores
    install_cores

    popd
}
