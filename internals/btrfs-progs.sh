BTRFS_VERSION="4.8"
BTRFS_CHECKSUM="51f907a15c60fd43a7e97a03b24928a1"
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
    ./configure --prefix /usr --disable-documentation
}

compile_btrfs() {
    make ${MAKEOPTS}
}

install_btrfs() {
    make DESTDIR="${ROOTDIR}" install
}

build_btrfs() {
    pushd "${WORKDIR}/btrfs-progs-v${BTRFS_VERSION}"

    prepare_btrfs
    compile_btrfs
    install_btrfs

    popd
}
