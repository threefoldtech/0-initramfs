RSCOREUTILS_VERSION="91899b34b96da40797846f343f399ca420777c6a"
RSCOREUTILS_CHECKSUM="b85c3e1328d6469b2a3b02baed7d2a05"
RSCOREUTILS_LINK="https://github.com/uutils/coreutils/archive/${RSCOREUTILS_VERSION}.tar.gz"

download_rscoreutils() {
    download_file ${RSCOREUTILS_LINK} ${RSCOREUTILS_CHECKSUM} rscoreutils-${RSCOREUTILS_VERSION}.tar.gz
}

extract_rscoreutils() {
    if [ ! -d "coreutils-${RSCOREUTILS_VERSION}" ]; then
        echo "[+] extracting: coreutils-${RSCOREUTILS_VERSION} (rscoreutils)"
        tar -xf ${DISTFILES}/rscoreutils-${RSCOREUTILS_VERSION}.tar.gz -C .
    fi
}

prepare_rscoreutils() {
    echo "[+] prepare coreutils (rscoreutils)"
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
    cp -va target/release/liblibstdbuf.so "${ROOTDIR}/lib/libstdbuf.so"
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
