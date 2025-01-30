FUSE_VERSION="2.9.9"
FUSE_CHECKSUM="23009734faca2f62d337e3a59be4c280"
FUSE_LINK="https://github.com/libfuse/libfuse/archive/fuse-${FUSE_VERSION}.tar.gz"

download_fuse() {
    download_file $FUSE_LINK $FUSE_CHECKSUM
}

extract_fuse() {
    if [ ! -d "libfuse-fuse-${FUSE_VERSION}" ]; then
        echo "[+] extracting: fuse-${FUSE_VERSION}"
        tar -xf ${DISTFILES}/fuse-${FUSE_VERSION}.tar.gz -C .
    fi
}

prepare_fuse() {
    echo "[+] preparing fuse"

    if [ ! -f .patched_fuse-2.9.9-closefrom-glibc-2-34.patch ]; then
        echo "[+] applying patch"
        patch -p1 < ${PATCHESDIR}/fuse-2.9.9-closefrom-glibc-2-34.patch
        touch .patched_fuse-2.9.9-closefrom-glibc-2-34.patch
    fi

    ./makeconf.sh
    ./configure --prefix /usr
}

compile_fuse() {
    echo "[+] compiling fuse"
    make ${MAKEOPTS}
}

install_fuse() {
    make DESTDIR="${ROOTDIR}" install
}

build_fuse() {
    pushd "${WORKDIR}/libfuse-fuse-${FUSE_VERSION}"

    prepare_fuse
    compile_fuse
    install_fuse

    popd
}

registrar_fuse() {
    DOWNLOADERS+=(download_fuse)
    EXTRACTORS+=(extract_fuse)
}

registrar_fuse
