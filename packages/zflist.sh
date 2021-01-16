ZFLIST_VERSION="2.0.0-rc1"
ZFLIST_CHECKSUM="c4dc7b9165c2024eaa0bc24cd26cb26a"
ZFLIST_LINK="https://github.com/threefoldtech/0-flist/archive/v${ZFLIST_VERSION}.tar.gz"

CAPNPC_VERSION="0.3"
CAPNPC_CHECKSUM="c1836601d210c14a4a88ed55e0b7c6de"
CAPNPC_LINK="https://github.com/opensourcerouting/c-capnproto/releases/download/c-capnproto-${CAPNPC_VERSION}/c-capnproto-${CAPNPC_VERSION}.tar.xz"

download_zflist() {
    download_file $ZFLIST_LINK $ZFLIST_CHECKSUM 0-flist-${ZFLIST_VERSION}.tar.gz
    download_file $CAPNPC_LINK $CAPNPC_CHECKSUM
}

extract_zflist() {
    if [ ! -d "0-flist-${ZFLIST_VERSION}" ]; then
        echo "[+] extracting: 0-flist-${ZFLIST_VERSION}"
        tar -xf ${DISTFILES}/0-flist-${ZFLIST_VERSION}.tar.gz -C .
    fi

    if [ ! -d "c-capnproto-${CAPNPC_VERSION}" ]; then
        echo "[+] extracting: c-capnproto-${CAPNPC_VERSION}"
        tar -xf ${DISTFILES}/c-capnproto-${CAPNPC_VERSION}.tar.xz -C .
    fi
}

build_capnpc() {
    echo "[+] preparing c-capnproto"
    autoreconf -f -i -s

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}

    make ${MAKEOPTS}
    make DESTDIR=${ROOTDIR} install
    ldconfig
}

prepare_zflist() {
    echo "[+] preparing zflist"
    make mrproper

    # fix flags override
    sed -i s/' = '/' += '/g libflist/Makefile
}

compile_zflist() {
    cd libflist
    make ${MAKEOPTS}
    cd ..

    cd zflist
    make production
    cd ..
}

install_zflist() {
    cp -avL zflist/zflist "${ROOTDIR}/usr/bin/"
}

build_zflist() {
    pushd "${WORKDIR}/c-capnproto-${CAPNPC_VERSION}"

    build_capnpc

    popd

    pushd "${WORKDIR}/0-flist-${ZFLIST_VERSION}"

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
