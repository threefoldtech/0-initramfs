UNIONFS_PKGNAME="unionfs-fuse"
UNIONFS_VERSION="2.0"
UNIONFS_CHECKSUM="40411d156ea7fa0e7cd0a8ec6fe60e70"
UNIONFS_LINK="https://github.com/rpodgorny/unionfs-fuse/archive/v${UNIONFS_VERSION}.tar.gz"

download_unionfs() {
    download_file $UNIONFS_LINK $UNIONFS_CHECKSUM ${UNIONFS_PKGNAME}-${UNIONFS_VERSION}.tar.gz
}

extract_unionfs() {
    if [ ! -d "${UNIONFS_PKGNAME}-${UNIONFS_VERSION}" ]; then
        progress "extracting: ${UNIONFS_PKGNAME}-${UNIONFS_VERSION}"
        tar -xf ${DISTFILES}/${UNIONFS_PKGNAME}-${UNIONFS_VERSION}.tar.gz -C .
    fi
}

compile_unionfs() {
    export CPPFLAGS="-D_FILE_OFFSET_BITS=64 -I${ROOTDIR}/usr/include"

    progress "compiling: ${UNIONFS_PKGNAME}"

    make LDFLAGS="$LDFLAGS -lfuse" ${MAKEOPTS}
}

install_unionfs() {
    progress "installing: ${UNIONFS_PKGNAME}"

    cp -a mount.unionfs "${ROOTDIR}"/usr/bin/
    cp -a src/unionfs "${ROOTDIR}"/usr/bin/
    cp -a src/unionfsctl "${ROOTDIR}"/usr/bin/
}

build_unionfs() {
    pushd "${WORKDIR}/${UNIONFS_PKGNAME}-${UNIONFS_VERSION}"

    compile_unionfs
    install_unionfs

    popd
}

registrar_unionfs() {
    DOWNLOADERS+=(download_unionfs)
    EXTRACTORS+=(extract_unionfs)
}

registrar_unionfs
