COREX_REPOSITORY="https://github.com/threefoldtech/corex"
COREX_BRANCH="staging"

LIBWEBSOCKETS_VERSION="2.4.2"
LIBWEBSOCKETS_CHECKSUM="b64300541128baa18828620187453efb"
LIBWEBSOCKETS_LINK="https://github.com/warmcat/libwebsockets/archive/v${LIBWEBSOCKETS_VERSION}.tar.gz"

download_corex() {
    download_git $COREX_REPOSITORY $COREX_BRANCH
    download_file $LIBWEBSOCKETS_LINK $LIBWEBSOCKETS_CHECKSUM libwebsockets-${LIBWEBSOCKETS_VERSION}.tar.gz
}

extract_corex() {
    event "refreshing" "corex-${COREX_BRANCH}"
    rm -rf ./corex-${COREX_BRANCH}
    cp -a ${DISTFILES}/corex ./corex-${COREX_BRANCH}

    if [ ! -d "libwebsockets-${LIBWEBSOCKETS_VERSION}" ]; then
        echo "[+] extracting: libwebsockets-${LIBWEBSOCKETS_VERSION}"
        tar -xf ${DISTFILES}/libwebsockets-${LIBWEBSOCKETS_VERSION}.tar.gz -C .
    fi
}

build_libwebsockets() {
    echo "[+] preparing libwebsocket"

    rm -rf build
    mkdir build

    pushd build

    cmake .. \
      -DLWS_UNIX_SOCK=ON \
      -DLWS_WITHOUT_TESTAPPS=ON \
      -DLWS_WITH_STATIC=OFF \
      -DLWS_IPV6=ON \
      -DLWS_OPENSSL_LIBRARIES=${ROOTDIR}/lib \
      -DLWS_OPENSSL_INCLUDE_DIRS=${ROOTDIR}/include

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
    echo "[+] installing corex"
    cp -avL build/corex "${ROOTDIR}/usr/bin/"

    echo "[+] building sandbox for corex"
    rm -rf "${ROOTDIR}/lib/corex"

    mkdir "${ROOTDIR}/lib/corex"
    mkdir "${ROOTDIR}/lib/corex/bin"

    cp -avL build/corex "${ROOTDIR}/lib/corex/bin/"
    ${TOOLSDIR}/lddcopy.sh "${ROOTDIR}/lib/corex/bin/corex" "${ROOTDIR}/lib/corex/"
}

inject_corex() {
    wget http://home.maxux.net/temp/corex-static-amd64 -O ${ROOTDIR}/usr/bin/corex
    chmod +x ${ROOTDIR}/usr/bin/corex
}

build_corex() {
    pushd "${WORKDIR}/libwebsockets-${LIBWEBSOCKETS_VERSION}"

    # build_libwebsockets

    popd

    pushd "${WORKDIR}/corex-${COREX_BRANCH}"

    # prepare_corex
    # compile_corex
    # install_corex
    inject_corex

    popd
}

registrar_corex() {
    DOWNLOADERS+=(download_corex)
    EXTRACTORS+=(extract_corex)
}

registrar_corex
