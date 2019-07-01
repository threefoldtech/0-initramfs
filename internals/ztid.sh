TF_HOME="${GOPATH}/src/github.com/threefoldtech"

ZTID_REPOSITORY="https://github.com/threefoldtech/ztid"
ZTID_VERSION="master"

download_ztid() {
    download_git ${ZTID_REPOSITORY} ${ZTID_VERSION}
}

extract_ztid() {
    event "refreshing ZTID-${ZTID_VERSION}"
    mkdir -p ${TF_HOME}
    rm -rf ${TF_HOME}/ztid
    cp -a ${DISTFILES}/ztid ${TF_HOME}/
}

prepare_ztid() {
    echo "[+] loading source code: ztid"
    pushd ztid
    go get -v ./...
    popd
}

compile_ztid() {
    echo "[+] compiling ztid"
    pushd ztid
    go build
    popd
}

install_ztid() {
    echo "[+] copying binaries"
    pushd ztid
    cp -a ztid "${ROOTDIR}/sbin/"
    popd
}

build_ztid() {
    mkdir -p $TF_HOME
    pushd $TF_HOME

    prepare_ztid
    compile_ztid
    install_ztid

    popd
}

registrar_ztid() {
    DOWNLOADERS+=(download_ztid)
    EXTRACTORS+=(extract_ztid)
}

registrar_ztid

