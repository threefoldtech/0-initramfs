FUSE_VERSION="2.9.7"
FUSE_CHECKSUM="91c97e5ae0a40312115dfecc4887bd9d"
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

    ./makeconf.sh
    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
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
