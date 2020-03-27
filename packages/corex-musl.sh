COREX_MUSL_PKGNAME="corex"
COREX_MUSL_REPOSITORY="https://github.com/threefoldtech/corex"
COREX_MUSL_BRANCH="staging"

download_corex_musl() {
    download_git $COREX_MUSL_REPOSITORY $COREX_MUSL_BRANCH
}

extract_corex_musl() {
    event "refreshing" "corex-${COREX_MUSL_BRANCH}"
    rm -rf ./${COREX_MUSL_PKGNAME}-${COREX_MUSL_BRANCH}
    cp -a ${DISTFILES}/corex ./${COREX_MUSL_PKGNAME}-${COREX_MUSL_BRANCH}
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
    pushd "${MUSLWORKDIR}/${COREX_MUSL_PKGNAME}-${COREX_MUSL_BRANCH}"

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
