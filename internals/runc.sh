RUNC_VERSION="1.0.0-rc9"
RUNC_CHECKSUM="e88bcb1a33e7ff0bfea495f7263826c2"
RUNC_LINK="https://github.com/opencontainers/runc/archive/v${RUNC_VERSION}.tar.gz"
RUNC_HOME="${GOPATH}/src/github.com/opencontainers"

download_runc() {
    download_file ${RUNC_LINK} ${RUNC_CHECKSUM} runc-v${RUNC_VERSION}.tar.gz
}

extract_runc() {
    #event "refreshing" "runc-${RUNC_BRANCH}"
    mkdir -p ${RUNC_HOME}
    rm -rf ${RUNC_HOME}/runc
    #cp -a ${DISTFILES}/runc ${RUNC_HOME}/

    pushd ${RUNC_HOME}

    echo "[+] extracting: runc-${RUNC_VERSION}"
    tar -xf ${DISTFILES}/runc-v${RUNC_VERSION}.tar.gz -C .
    mv runc-${RUNC_VERSION} runc

    popd
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
