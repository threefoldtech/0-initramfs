BTRFS_VERSION="4.20.2"
BTRFS_CHECKSUM="f5487352c734a73c7b1ccded3b126715"
BTRFS_LINK="https://www.kernel.org/pub/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${BTRFS_VERSION}.tar.xz"

download_btrfs() {
    download_file $BTRFS_LINK $BTRFS_CHECKSUM
}

extract_btrfs() {
    if [ ! -d "btrfs-progs-v${BTRFS_VERSION}" ]; then
        echo "[+] extracting: btrfs-progs-${BTRFS_VERSION}"
        tar -xf ${DISTFILES}/btrfs-progs-v${BTRFS_VERSION}.tar.xz -C .
    fi
}

prepare_btrfs() {
    echo "[+] configuring btrfs-progs"

    export LIBS="-lblkid -luuid"
    # export CFLAGS="-I${ROOTDIR}/usr/include/ -g -O1 -Wall -D_FORTIFY_SOURCE=2"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-documentation \
        --disable-convert \
        --disable-zstd \
        --disable-python
}

compile_btrfs() {
    make ${MAKEOPTS}
}

install_btrfs() {
    make DESTDIR="${ROOTDIR}" install

    unset LIBS
}

build_btrfs() {
    pushd "${WORKDIR}/btrfs-progs-v${BTRFS_VERSION}"

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
