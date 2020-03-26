ZFLIST_REPOSITORY="https://github.com/threefoldtech/0-flist"
ZFLIST_BRANCH="development"

CAPNPC_VERSION="0.3"
CAPNPC_CHECKSUM="c1836601d210c14a4a88ed55e0b7c6de"
CAPNPC_LINK="https://github.com/opensourcerouting/c-capnproto/releases/download/c-capnproto-${CAPNPC_VERSION}/c-capnproto-${CAPNPC_VERSION}.tar.xz"

download_zflist() {
    download_git $ZFLIST_REPOSITORY $ZFLIST_BRANCH
    download_file $CAPNPC_LINK $CAPNPC_CHECKSUM
}

extract_zflist() {
    event "refreshing" "zflist-${ZFLIST_BRANCH}"
    rm -rf ./zflist-${ZFLIST_BRANCH}
    cp -a ${DISTFILES}/0-flist ./zflist-${ZFLIST_BRANCH}

    if [ ! -d "c-capnproto-${CAPNPC_VERSION}" ]; then
        echo "[+] extracting: c-capnproto-${CAPNPC_VERSION}"
        tar -xf ${DISTFILES}/c-capnproto-${CAPNPC_VERSION}.tar.xz -C .
    fi
}

build_capnpc() {
    echo "[+] preparing c-capnproto"
    autoreconf -f -i -s
    ./configure
    make ${MAKEOPTS}
    make install
    ldconfig
}

prepare_zflist() {
    echo "[+] preparing zflist"
    make mrproper
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

    pushd "${WORKDIR}/zflist-${ZFLIST_BRANCH}"

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
