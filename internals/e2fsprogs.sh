E2FSPROGS_VERSION="1.44.1"
E2FSPROGS_CHECKSUM="2394abc32a0af72ed1ebb5b903e9c57d"
E2FSPROGS_LINK="https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${E2FSPROGS_VERSION}/e2fsprogs-${E2FSPROGS_VERSION}.tar.xz"

E2FSPROGS_LIBS_VERSION=$E2FSPROGS_VERSION
E2FSPROGS_LIBS_CHECKSUM="01fcff0c42f8c0a4865e5bc4fe00e156"
E2FSPROGS_LIBS_LINK="https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${E2FSPROGS_LIBS_VERSION}/e2fsprogs-libs-${E2FSPROGS_LIBS_VERSION}.tar.xz"

download_e2fsprogs() {
    download_file $E2FSPROGS_LINK $E2FSPROGS_CHECKSUM
    download_file $E2FSPROGS_LIBS_LINK $E2FSPROGS_LIBS_CHECKSUM
}

extract_e2fsprogs() {
    if [ ! -d "e2fsprogs-${E2FSPROGS_VERSION}" ]; then
        echo "[+] extracting: e2fsprogs-${E2FSPROGS_VERSION}"
        tar -xf ${DISTFILES}/e2fsprogs-${E2FSPROGS_VERSION}.tar.xz -C .
    fi

    if [ ! -d "e2fsprogs-libs-${E2FSPROGS_LIBS_VERSION}" ]; then
        echo "[+] extracting: e2fsprogs-libs-${E2FSPROGS_LIBS_VERSION}"
        tar -xf ${DISTFILES}/e2fsprogs-libs-${E2FSPROGS_LIBS_VERSION}.tar.xz -C .
    fi
}

prepare_e2fsprogs() {
    echo "[+] configuring e2fsprogs"
    ./configure --prefix "${ROOTDIR}"/usr
}

compile_e2fsprogs() {
    make ${MAKEOPTS}
}

install_e2fsprogs() {
    make install
}


prepare_e2fsprogs_libs() {
    echo "[+] configuring e2fsprogs-libs"

    export LDFLAGS="-L${ROOTDIR}/usr/lib/"
    export CFLAGS="-I${ROOTDIR}/usr/include"

    ./configure --prefix "${ROOTDIR}"/usr \
        --disable-libuuid \
        --disable-libblkid
}

compile_e2fsprogs_libs() {
    make ${MAKEOPTS}
}

install_e2fsprogs_libs() {
    make install

    unset LDFLAGS
    unset CFLAGS
}


build_e2fsprogs() {
    pushd "${WORKDIR}/e2fsprogs-${E2FSPROGS_VERSION}"

    prepare_e2fsprogs
    compile_e2fsprogs
    install_e2fsprogs

    popd

    pushd "${WORKDIR}/e2fsprogs-libs-${E2FSPROGS_LIBS_VERSION}"

    prepare_e2fsprogs_libs
    compile_e2fsprogs_libs
    install_e2fsprogs_libs

    popd
}

registrar_e2fsprogs() {
    DOWNLOADERS+=(download_e2fsprogs)
    EXTRACTORS+=(extract_e2fsprogs)
}

registrar_e2fsprogs
