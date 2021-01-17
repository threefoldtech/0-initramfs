CAPNPC_PKGNAME="c-capnproto"
CAPNPC_VERSION="0.3"
CAPNPC_CHECKSUM="c1836601d210c14a4a88ed55e0b7c6de"
CAPNPC_LINK="https://github.com/opensourcerouting/c-capnproto/releases/download/c-capnproto-${CAPNPC_VERSION}/c-capnproto-${CAPNPC_VERSION}.tar.xz"

download_capnpc() {
    download_file $CAPNPC_LINK $CAPNPC_CHECKSUM
}

extract_capnpc() {
    if [ ! -d "${CAPNPC_PKGNAME}-${CAPNPC_VERSION}" ]; then
        progress "extracting: ${CAPNPC_PKGNAME}-${CAPNPC_VERSION}"
        tar -xf ${DISTFILES}/${CAPNPC_PKGNAME}-${CAPNPC_VERSION}.tar.xz -C .
    fi
}

prepare_capnpc() {
    progress "preparing: ${CAPNPC_PKGNAME}"
    autoreconf -f -i -s

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_capnpc() {
    progress "compiling: ${CAPNPC_VERSION}"

    make ${MAKEOPTS}
}

install_capnpc() {
    progress "installing: ${CAPNPC_PKGNAME}"

    make DESTDIR=${ROOTDIR} install
    ldconfig
}

build_capnpc() {
    pushd "${WORKDIR}/${CAPNPC_PKGNAME}-${CAPNPC_VERSION}"

    prepare_capnpc
    compile_capnpc
    install_capnpc

    popd
}

registrar_capnpc() {
    DOWNLOADERS+=(download_capnpc)
    EXTRACTORS+=(extract_capnpc)
}

registrar_capnpc
