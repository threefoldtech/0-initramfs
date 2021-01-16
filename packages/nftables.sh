NFTABLES_PKGNAME="nftables"
NFTABLES_VERSION="0.9.1"
NFTABLES_CHECKSUM="e2facbcad6c5d9bd87a0bf5081a31522"
NFTABLES_LINK="https://www.netfilter.org/projects/nftables/files/nftables-${NFTABLES_VERSION}.tar.bz2"

download_nftables() {
    download_file $NFTABLES_LINK $NFTABLES_CHECKSUM
}

extract_nftables() {
    if [ ! -d "${NFTABLES_PKGNAME}-${NFTABLES_VERSION}" ]; then
        progress "extracting: ${NFTABLES_PKGNAME}-${NFTABLES_VERSION}"
        tar -xf ${DISTFILES}/${NFTABLES_PKGNAME}-${NFTABLES_VERSION}.tar.bz2 -C .
    fi
}

prepare_nftables() {
    progress "preparing: nftables"

    # LIBS fixes readline link
    LIBS="-lncurses -lmnl -lnftnl" ./configure \
        --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-debug \
        --with-cli \
        --with-json \
        --with-mini-gmp \
        --with-sysroot=${ROOTDIR} \
        --disable-man-doc
}

compile_nftables() {
    progress "compiling: nftables"

    make V=1 ${MAKEOPTS}
}

install_nftables() {
    progress "installing: nftables"

    make DESTDIR=${ROOTDIR} install
}

build_nftables() {
    pushd "${WORKDIR}/nftables-${NFTABLES_VERSION}"

    prepare_nftables
    compile_nftables
    install_nftables

    popd
}

registrar_nftables() {
    DOWNLOADERS+=(download_nftables)
    EXTRACTORS+=(extract_nftables)
}

registrar_nftables
