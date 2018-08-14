ZFLIST_REPOSITORY="https://github.com/threefoldtech/0-flist"
ZFLIST_BRANCH="development"

CAPNPC_REPOSITORY="https://github.com/opensourcerouting/c-capnproto"
CAPNPC_BRANCH="master"

download_zflist() {
    download_git $ZFLIST_REPOSITORY $ZFLIST_BRANCH
    download_git $CAPNPC_REPOSITORY $CAPNPC_BRANCH

    pushd ${DISTFILES}/c-capnproto
    git submodule update --init --recursive
    popd
}

extract_zflist() {
    event "refreshing" "zflist-${ZFLIST_BRANCH}"
    rm -rf ./zflist-${ZFLIST_BRANCH}
    cp -a ${DISTFILES}/0-flist ./zflist-${ZFLIST_BRANCH}

    rm -rf ./c-capnproto-${CAPNPC_BRANCH}
    cp -a ${DISTFILES}/c-capnproto ./c-capnproto-${CAPNPC_BRANCH}
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
    pushd "${WORKDIR}/c-capnproto-${CAPNPC_BRANCH}"

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
