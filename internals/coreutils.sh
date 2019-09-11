COREUTILS_REPOSITORY="https://github.com/uutils/coreutils.git"
COREUTILS_VERSION="master"

download_coreutils() {
    download_git ${COREUTILS_REPOSITORY} ${COREUTILS_VERSION}
}

extract_coreutils() {
    event "refreshing" "coreutils-${COREUTILS_VERSION}"
    rm -rf ./coreutils-${COREUTILS_VERSION}
    cp -a ${DISTFILES}/coreutils ./coreutils-${COREUTILS_VERSION}
}

prepare_coreutils() {
    echo "[+] loading source code: coreutils"
}

compile_coreutils() {
    echo "[+] compiling coreutils"
    # we only compile libstdbuf because that's all what
    # we need from library.
    pushd src/stdbuf/libstdbuf
    
    cargo --build release

    popd
}

install_coreutils() {
    echo "[+] copying binaries"
    cp -a target/release/liblibstdbuf.so "${ROOTDIR}/lib/libstdbuf.so"
}

build_coreutils() {
    pushd "${WORKDIR}/coreutils-${COREUTILS_VERSION}"

    prepare_coreutils
    compile_coreutils
    install_coreutils

    popd
}

registrar_coreutils() {
    DOWNLOADERS+=(download_coreutils)
    EXTRACTORS+=(extract_coreutils)
}

registrar_coreutils

