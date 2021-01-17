ZFLIST_PKGNAME="0-flist"
ZFLIST_VERSION="2.0.0-rc1"
ZFLIST_CHECKSUM="c4dc7b9165c2024eaa0bc24cd26cb26a"
ZFLIST_LINK="https://github.com/threefoldtech/0-flist/archive/v${ZFLIST_VERSION}.tar.gz"

download_zflist() {
    download_file $ZFLIST_LINK $ZFLIST_CHECKSUM ${ZFLIST_PKGNAME}-${ZFLIST_VERSION}.tar.gz
}

extract_zflist() {
    if [ ! -d "${ZFLIST_PKGNAME}-${ZFLIST_VERSION}" ]; then
        progress "extracting: ${ZFLIST_PKGNAME}-${ZFLIST_VERSION}"
        tar -xf ${DISTFILES}/${ZFLIST_PKGNAME}-${ZFLIST_VERSION}.tar.gz -C .
    fi
}

prepare_zflist() {
    progress "preparing: ${ZFLIST_PKGNAME}"

    # fix flags override
    sed -i s/' = '/' += '/g libflist/Makefile
}

compile_zflist() {
    progress "compiling: ${ZFLIST_PKGNAME}"

    cd libflist
    make ${MAKEOPTS}
    cd ..

    cd zflist
    make production
    cd ..
}

install_zflist() {
    progress "installing: ${ZFLIST_PKGNAME}"

    cp -avL zflist/zflist "${ROOTDIR}/usr/bin/"
}

build_zflist() {
    pushd "${WORKDIR}/${ZFLIST_PKGNAME}-${ZFLIST_VERSION}"

    prepare_zflist
    compile_zflist
    install_zflist

    popd
}

registrar_zflist() {
    DOWNLOADERS+=(download_zflist)
    EXTRACTORS+=(extract_zflist)
}

registrar_zflist
