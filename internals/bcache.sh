BCACHE_VERSION="494f8d187c74f557dfebbb5dc3591453436b507b"
BCACHE_CHECKSUM="a698ee9ecd6f481070adfd5acfc881b5"
BCACHE_LINK="https://github.com/koverstreet/bcache-tools/archive/${BCACHE_VERSION}.tar.gz"

download_bcache() {
    download_file $BCACHE_LINK $BCACHE_CHECKSUM bcache-tools-${BCACHE_VERSION}.tar.gz
}

extract_bcache() {
    if [ ! -d "bcache-tools-${BCACHE_VERSION}" ]; then
        echo "[+] extracting: bcache-tools-${BCACHE_VERSION}"
        tar -xf ${DISTFILES}/bcache-tools-${BCACHE_VERSION}.tar.gz -C .
    fi
}

prepare_bcache() {
    echo "[+] preparing bcache-tools"

    if [ ! -f .patched_bcache-tools-gcc5.patch ]; then
        echo "[+] patching bcache-tools"
        patch -p1 < ${PATCHESDIR}/bcache-tools-gcc5.patch
        touch .patched_bcache-tools-gcc5.patch
    fi
}

compile_bcache() {
    make ${MAKEOPTS}
}

install_bcache() {
    make DESTDIR=${ROOTDIR} install
}

build_bcache() {
    pushd "${WORKDIR}/bcache-tools-${BCACHE_VERSION}"

    prepare_bcache
    compile_bcache
    install_bcache

    popd
}

registrar_bcache() {
    DOWNLOADERS+=(download_bcache)
    EXTRACTORS+=(extract_bcache)
}

registrar_bcache

