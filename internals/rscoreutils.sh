RSCOREUTILS_REPOSITORY="https://github.com/uutils/coreutils.git"
RSCOREUTILS_VERSION="master"

download_rscoreutils() {
    download_git ${RSCOREUTILS_REPOSITORY} ${RSCOREUTILS_VERSION}
}

extract_rscoreutils() {
    event "refreshing" "coreutils-${RSCOREUTILS_VERSION}"
    rm -rf ./coreutils-${RSCOREUTILS_VERSION}
    cp -va ${DISTFILES}/coreutils ./coreutils-${RSCOREUTILS_VERSION}
}

prepare_rscoreutils() {
    echo "[+] loading source code: coreutils"
}

compile_rscoreutils() {
    echo "[+] compiling coreutils"
    # we only compile libstdbuf because that's all what
    # we need from library.
    pushd src/stdbuf/libstdbuf

    cargo build --release

    popd
}

install_rscoreutils() {
    echo "[+] copying binaries"
    cp -a target/release/liblibstdbuf.so "${ROOTDIR}/lib/libstdbuf.so"
}

build_rscoreutils() {
    pushd "${WORKDIR}/coreutils-${RSCOREUTILS_VERSION}"

    prepare_rscoreutils
    compile_rscoreutils
    install_rscoreutils

    popd
}

registrar_rscoreutils() {
    DOWNLOADERS+=(download_rscoreutils)
    EXTRACTORS+=(extract_rscoreutils)
}

registrar_rscoreutils
