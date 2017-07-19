ORK_VERSION="master"
ORK_LINK="github.com/zero-os/0-ork"

prepare_ork() {
    echo "[+] loading source code: 0-ork"
    go get -d -v "${ORK_LINK}"

    echo "[+] ensure 0-ork to branch: ${ORK_VERSION}"
    pushd "$GOPATH/src/${ORK_LINK}"
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "${ORK_VERSION}" ]; then
        git fetch origin "${ORK_VERSION}:${ORK_VERSION}"
        git checkout "${ORK_VERSION}"
    fi

    git pull origin "${ORK_VERSION}"
    popd

}

compile_ork() {
    echo "[+] compiling 0-ork"
    go build
}

install_ork() {
    echo "[+] copying binaries"
    cp -a 0-ork "${ROOTDIR}/sbin/"
}

build_ork() {
    # We need to prepare first (download code)
    prepare_ork
    pushd $GOPATH/src/github.com/zero-os/0-ork

    compile_ork
    install_ork

    popd
}
