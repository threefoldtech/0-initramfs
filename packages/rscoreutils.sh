RSCOREUTILS_PKGNAME="coreutils"
RSCOREUTILS_VERSION="91899b34b96da40797846f343f399ca420777c6a"
RSCOREUTILS_CHECKSUM="b85c3e1328d6469b2a3b02baed7d2a05"
RSCOREUTILS_LINK="https://github.com/uutils/coreutils/archive/${RSCOREUTILS_VERSION}.tar.gz"

download_rscoreutils() {
    download_file ${RSCOREUTILS_LINK} ${RSCOREUTILS_CHECKSUM} rscoreutils-${RSCOREUTILS_VERSION}.tar.gz
}

extract_rscoreutils() {
    if [ ! -d "${RSCOREUTILS_PKGNAME}-${RSCOREUTILS_VERSION}" ]; then
        progress "extracting: coreutils-${RSCOREUTILS_VERSION} (rscoreutils)"
        tar -xf ${DISTFILES}/rscoreutils-${RSCOREUTILS_VERSION}.tar.gz -C .
    fi
}

compile_rscoreutils() {
    progress "compiling: rscoreutils"

    # we only compile libstdbuf because that's all what
    # we need from library.
    pushd src/stdbuf/libstdbuf

    # save current flag
    export XBUILDRUST=${BUILDRUST}

    if [ "${BUILDARCH}" == "x86" ]; then
        # do not use musl as target
        export BUILDRUST="x86_64-unknown-linux-gnu"
    fi

    cargo build --release --target=${BUILDRUST}
    popd
}

install_rscoreutils() {
    progress "installing: rscoreutils"

    cp -va target/${BUILDRUST}/release/liblibstdbuf.so "${ROOTDIR}/lib/libstdbuf.so"

    # restore previous flag
    export BUILDRUST=${XBUILDRUST}
}

build_rscoreutils() {
    pushd "${WORKDIR}/${RSCOREUTILS_PKGNAME}-${RSCOREUTILS_VERSION}"

    compile_rscoreutils
    install_rscoreutils

    popd
}

registrar_rscoreutils() {
    DOWNLOADERS+=(download_rscoreutils)
    EXTRACTORS+=(extract_rscoreutils)
}

registrar_rscoreutils
