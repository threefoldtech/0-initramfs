LIBNFTNL_PKGNAME="libnftnl"
LIBNFTNL_VERSION="1.1.9"
LIBNFTNL_CHECKSUM="e03cefd53f4b076d959abe36de5c38f8"
LIBNFTNL_LINK="http://www.iptables.org/projects/libnftnl/files/libnftnl-${LIBNFTNL_VERSION}.tar.bz2"

download_libnftnl() {
    download_file $LIBNFTNL_LINK $LIBNFTNL_CHECKSUM
}

extract_libnftnl() {
    if [ ! -d "${LIBNFTNL_PKGNAME}-${LIBNFTNL_VERSION}" ]; then
        progress "extracting: ${LIBNFTNL_PKGNAME}-${LIBNFTNL_VERSION}"
        tar -xf ${DISTFILES}/${LIBNFTNL_PKGNAME}-${LIBNFTNL_VERSION}.tar.bz2 -C .
    fi
}

prepare_libnftnl() {
    progress "prepare: ${LIBNFTNL_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --with-sysroot=${ROOTDIR}
    }

compile_libnfnl() {
    progress "compiling: ${LIBNFTNL_PKGNAME}"

    make ${MAKEOPTS}
}

install_libnftnl() {
    progress "installing: ${LIBNFTNL_PKGNAME}"

    make DESTDIR=${ROOTDIR} install
}

build_libnftnl() {
    pushd "${WORKDIR}/libnftnl-${LIBNFTNL_VERSION}"

    prepare_libnftnl
    compile_libnfnl
    install_libnftnl

    popd
}

registrar_libnftnl() {
    DOWNLOADERS+=(download_libnftnl)
    EXTRACTORS+=(extract_libnftnl)
}

registrar_libnftnl
