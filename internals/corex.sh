COREX_REPOSITORY="https://github.com/threefoldtech/corex"
COREX_BRANCH="staging"

LIBWEBSOCKETS_REPOSITORY="https://github.com/warmcat/libwebsockets"
LIBWEBSOCKETS_BRANCH="v2.4.2"

download_corex() {
    download_git $COREX_REPOSITORY $COREX_BRANCH
    download_git $LIBWEBSOCKETS_REPOSITORY $LIBWEBSOCKETS_BRANCH
}

extract_corex() {
    event "refreshing" "corex-${COREX_BRANCH}"
    rm -rf ./corex-${COREX_BRANCH}
    cp -a ${DISTFILES}/corex ./corex-${COREX_BRANCH}

    event "refreshing" "libwebsockets-${LIBWEBSOCKETS_BRANCH}"
    rm -rf ./libwebsockets-${LIBWEBSOCKETS_BRANCH}
    cp -a ${DISTFILES}/libwebsockets ./libwebsockets-${LIBWEBSOCKETS_BRANCH}
}

build_libwebsockets() {
    echo "[+] preparing libwebsocket"

    rm -rf build
    mkdir build

    pushd build

    cmake .. -DLWS_UNIX_SOCK=ON -DLWS_WITHOUT_TESTAPPS=ON -DLWS_WITH_STATIC=OFF
    make -j ${MAKEOPTS}
    make install

    popd
}

prepare_corex() {
    echo "[+] preparing corex"

    rm -rf build
    mkdir build

    pushd build

    cmake ..

    popd
}

compile_corex() {
    pushd build
    make ${MAKEOPTS}
    popd
}

install_corex() {
    cp -avL build/corex "${ROOTDIR}/usr/bin/"
}

build_corex() {
    pushd "${WORKDIR}/libwebsockets-${LIBWEBSOCKETS_BRANCH}"

    build_libwebsockets

    popd

    pushd "${WORKDIR}/corex-${COREX_BRANCH}"

    prepare_corex
    compile_corex
    install_corex

    popd
}

registrar_corex() {
    DOWNLOADERS+=(download_corex)
    EXTRACTORS+=(extract_corex)
}

registrar_corex
