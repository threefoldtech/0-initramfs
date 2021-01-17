BTRFS_PKGNAME="btrfs-progs"
BTRFS_VERSION="4.20.2"
BTRFS_CHECKSUM="f5487352c734a73c7b1ccded3b126715"
BTRFS_LINK="https://www.kernel.org/pub/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${BTRFS_VERSION}.tar.xz"

download_btrfs() {
    download_file $BTRFS_LINK $BTRFS_CHECKSUM
}

extract_btrfs() {
    if [ ! -d "${BTRFS_PKGNAME}-v${BTRFS_VERSION}" ]; then
        progress "extracting: ${BTRFS_PKGNAME}-${BTRFS_VERSION}"
        tar -xf ${DISTFILES}/${BTRFS_PKGNAME}-v${BTRFS_VERSION}.tar.xz -C .
    fi
}

prepare_btrfs() {
    progress "configuring: ${BTRFS_PKGNAME}"

    # export CFLAGS="-I${ROOTDIR}/usr/include/ -g -O1 -Wall -D_FORTIFY_SOURCE=2"

    LIBS="-lblkid -luuid" ./configure \
        --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-documentation \
        --disable-convert \
        --disable-zstd \
        --disable-python
}

compile_btrfs() {
    progress "compiling: ${BTRFS_PKGNAME}"

    make ${MAKEOPTS}
}

install_btrfs() {
    progress "installing: ${BTRFS_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_btrfs() {
    pushd "${WORKDIR}/${BTRFS_PKGNAME}-v${BTRFS_VERSION}"

    prepare_btrfs
    compile_btrfs
    install_btrfs

    popd
}

registrar_btrfs() {
    DOWNLOADERS+=(download_btrfs)
    EXTRACTORS+=(extract_btrfs)
}

registrar_btrfs
