RUNC_REPOSITORY="https://github.com/opencontainers/runc"
RUNC_BRANCH="v1.0.0-rc8"
RUNC_HOME="${GOPATH}/src/github.com/opencontainers"

download_runc() {
    download_git ${RUNC_REPOSITORY} ${RUNC_BRANCH}
}

extract_runc() {
    event "refreshing" "runc-${RUNC_BRANCH}"
    rm -rf ${RUNC_HOME}/runc
    cp -a ${DISTFILES}/runc ${RUNC_HOME}/

}

prepare_runc() {
    echo "[+] prepare runc"
}

compile_runc() {
    echo "[+] compiling runc"
    make BUILDTAGS='seccomp'
}

install_runc() {
    echo "[+] copying binaries"
    cp -av runc "${ROOTDIR}/usr/bin/"
}

build_runc() {
    pushd ${RUNC_HOME}/runc

    prepare_runc
    compile_runc
    install_runc

    popd
}


registrar_runc() {
    DOWNLOADERS+=(download_runc)
    EXTRACTORS+=(extract_runc)
}

registrar_runc
