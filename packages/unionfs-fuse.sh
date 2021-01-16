UNIONFS_VERSION="2.0"
UNIONFS_CHECKSUM="40411d156ea7fa0e7cd0a8ec6fe60e70"
UNIONFS_LINK="https://github.com/rpodgorny/unionfs-fuse/archive/v${UNIONFS_VERSION}.tar.gz"

download_unionfs() {
    download_file $UNIONFS_LINK $UNIONFS_CHECKSUM unionfs-fuse-${UNIONFS_VERSION}.tar.gz
}

extract_unionfs() {
    if [ ! -d "unionfs-fuse-${UNIONFS_VERSION}" ]; then
        echo "[+] extracting: unionfs-fuse-${UNIONFS_VERSION}"
        tar -xf ${DISTFILES}/unionfs-fuse-${UNIONFS_VERSION}.tar.gz -C .
    fi
}

prepare_unionfs() {
    echo "[+] preparing unionfs-fuse"
}

compile_unionfs() {
    export CPPFLAGS="-D_FILE_OFFSET_BITS=64 -I${ROOTDIR}/usr/include"

    echo "[+] compiling unionfs-fuse"
    make LDFLAGS="$LDFLAGS -lfuse" ${MAKEOPTS}
}

install_unionfs() {
    echo "[+] installing unionfs-fuse"
    cp -a mount.unionfs "${ROOTDIR}"/usr/bin/
    cp -a src/unionfs "${ROOTDIR}"/usr/bin/
    cp -a src/unionfsctl "${ROOTDIR}"/usr/bin/
}

build_unionfs() {
    pushd "${WORKDIR}/unionfs-fuse-${UNIONFS_VERSION}"

    prepare_unionfs
    compile_unionfs
    install_unionfs

    popd
}

registrar_unionfs() {
    DOWNLOADERS+=(download_unionfs)
    EXTRACTORS+=(extract_unionfs)
}

registrar_unionfs
