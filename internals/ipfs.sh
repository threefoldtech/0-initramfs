IPFS_VERSION="v0.4.4"

prepare_ipfs() {
    echo "[+] loading source code: ipfs"
    go get -d -v github.com/ipfs/go-ipfs

    pushd "$GOPATH/src/github.com/ipfs/go-ipfs"

    if [ "$(git describe)" != "${IPFS_VERSION}" ]; then
        git checkout ${IPFS_VERSION}
    fi

    if [ ! -f ipfs-dist_get.patch ]; then
        echo "[+] downloading patch"
        curl -s https://gist.githubusercontent.com/maxux/a5472530dd88b3480d745388d81e4c7f/raw/040c8c17be8e71035b8484866c3ef69555e1a61d/ipfs-dist_get.patch > ipfs-dist_get.patch
        patch -p0 < ipfs-dist_get.patch
    fi

    popd
}

compile_ipfs() {
    echo "[+] compiling dependancies"
    make deps

    echo "[+] compiling ipfs"
    pushd cmd/ipfs
    go build -i -ldflags="-X "github.com/ipfs/go-ipfs/repo/config".CurrentCommit=d905d48 -w -s"
    popd
}

install_ipfs() {
    echo "[+] installing ipfs"
    cp -a cmd/ipfs/ipfs "${ROOTDIR}"/usr/bin/
}

build_ipfs() {
    prepare_ipfs
    pushd "$GOPATH/src/github.com/ipfs/go-ipfs"

    compile_ipfs
    install_ipfs

    popd
}
