ORK_VERSION="master"
ORK_LINK="github.com/threefoldtech/0-ork"

prepare_ork() {
    progress "loading source code: 0-ork"
    go get -d -v "${ORK_LINK}"

    progress "ensure 0-ork to branch: ${ORK_VERSION}"
    pushd "$GOPATH/src/${ORK_LINK}"
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "${ORK_VERSION}" ]; then
        git fetch origin "${ORK_VERSION}:${ORK_VERSION}"
        git checkout "${ORK_VERSION}"
    fi

    git pull origin "${ORK_VERSION}"
    go get -v ./...
    popd

}

compile_ork() {
    progress "compiling 0-ork"
    go build
}

install_ork() {
    progress "copying binaries"
    cp -a 0-ork "${ROOTDIR}/sbin/"
}

build_ork() {
    # We need to prepare first (download code)
    prepare_ork
    pushd $GOPATH/src/github.com/threefoldtech/0-ork

    compile_ork
    install_ork

    popd
}
