CORES_VERSION="master"

prepare_cores() {
    echo "[+] loading source code: g8os cores"
    go get -d -v github.com/g8os/core0/core0
    go get -d -v github.com/g8os/core0/coreX
    go get -d -v github.com/g8os/g8ufs
}

compile_cores() {
    echo "[+] compiling coreX and core0"
    make

    echo "[+] compiling g8ufs"
    pushd ../g8ufs/cmd
    go build -ldflags "-s -w"
    popd
}

install_cores() {
    echo "[+] copying binaries"
    cp -a bin/coreX bin/core0 "${ROOTDIR}/sbin/"
    cp -a ../g8ufs/cmd/cmd "${ROOTDIR}/sbin/g8ufs"

    echo "[+] installing configuration"
    mkdir -p "${ROOTDIR}/etc/g8os/conf"
    cp -a core0/conf/* "${ROOTDIR}"/etc/g8os/conf/
    rm -f "${ROOTDIR}"/etc/g8os/conf/README.md
}

build_cores() {
    # We need to prepare first (download code)
    prepare_cores
    pushd $GOPATH/src/github.com/g8os/core0

    compile_cores
    install_cores

    popd
}
