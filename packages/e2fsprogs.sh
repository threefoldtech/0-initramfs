E2FSPROGS_VERSION="1.45.2"
E2FSPROGS_CHECKSUM="d15898253dda2e5bce85593022e82432"
E2FSPROGS_LINK="https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${E2FSPROGS_VERSION}/e2fsprogs-${E2FSPROGS_VERSION}.tar.xz"

download_e2fsprogs() {
    download_file $E2FSPROGS_LINK $E2FSPROGS_CHECKSUM
}

extract_e2fsprogs() {
    if [ ! -d "e2fsprogs-${E2FSPROGS_VERSION}" ]; then
        echo "[+] extracting: e2fsprogs-${E2FSPROGS_VERSION}"
        tar -xf ${DISTFILES}/e2fsprogs-${E2FSPROGS_VERSION}.tar.xz -C .
    fi
}

prepare_e2fsprogs() {
    echo "[+] configuring e2fsprogs"
    ./configure --prefix="${ROOTDIR}"/usr \
        --enable-subset \
        --enable-symlink-install \
        --enable-relative-symlinks \
        --enable-symlink-build \
        --disable-debugfs \
        --disable-defrag \
        --disable-e2initrd-helper \
        --disable-fuse2fs
}

compile_e2fsprogs() {
    make ${MAKEOPTS}
}

install_e2fsprogs() {
    make install
}

build_e2fsprogs() {
    pushd "${WORKDIR}/e2fsprogs-${E2FSPROGS_VERSION}"

    prepare_e2fsprogs
    compile_e2fsprogs
    install_e2fsprogs

    popd
}

registrar_e2fsprogs() {
    DOWNLOADERS+=(download_e2fsprogs)
    EXTRACTORS+=(extract_e2fsprogs)
}

registrar_e2fsprogs
