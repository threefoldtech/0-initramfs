COREX_MUSL_PKGNAME="corex"
COREX_MUSL_VERSION="2.1.0"
COREX_MUSL_CHECKSUM="2062aaca7609a6f50a67d4ef7d6221a7"
COREX_MUSL_LINK="https://github.com/threefoldtech/corex/archive/${COREX_MUSL_VERSION}.tar.gz"

download_corex_musl() {
    download_file ${COREX_MUSL_LINK} ${COREX_MUSL_CHECKSUM} corex-${COREX_MUSL_VERSION}.tar.gz
}

extract_corex_musl() {
    if [ ! -d "${COREX_MUSL_PKGNAME}-${COREX_MUSL_VERSION}" ]; then
        echo "[+] extracting: ${COREX_MUSL_PKGNAME}-${COREX_MUSL_VERSION}"
        tar -xf ${DISTFILES}/${COREX_MUSL_PKGNAME}-${COREX_MUSL_VERSION}.tar.gz -C .
    fi
}

prepare_corex_musl() {
    echo "[+] preparing: corex"
}

compile_corex_musl() {
    echo "[+] compiling: corex"
    pushd src

    export CFLAGS="-I${MUSLROOTDIR}/include -I${MUSLROOTDIR}/include/json-c"
    export LDFLAGS="-L${MUSLROOTDIR}/lib"

    CC="musl-gcc" make ${MAKEOPTS}

    unset CFLAGS
    unset LDFLAGS

    popd
}

install_corex_musl() {
    echo "[+] installing: corex"
    cp -avL src/corex "${ROOTDIR}/usr/bin/"
}

build_corex_musl() {
    pushd "${MUSLWORKDIR}/${COREX_MUSL_PKGNAME}-${COREX_MUSL_VERSION}"

    prepare_corex_musl
    compile_corex_musl
    install_corex_musl

    popd
}

registrar_corex_musl() {
    DOWNLOADERS+=(download_corex_musl)
    EXTRACTORS+=(extract_corex_musl)
}

registrar_corex_musl
