XZ_VERSION="5.2.5"
XZ_CHECKSUM="0d270c997aff29708c74d53f599ef717"
XZ_LINK="https://tukaani.org/xz/xz-${XZ_VERSION}.tar.gz"

download_xz() {
    download_file $XZ_LINK $XZ_CHECKSUM
}

extract_xz() {
    if [ ! -d "xz-${XZ_VERSION}" ]; then
        echo "[+] extracting: xz-${XZ_VERSION}"
        tar -xf ${DISTFILES}/xz-${XZ_VERSION}.tar.gz -C .
    fi
}

prepare_xz() {
    echo "[+] preparing xz"

    ./configure --prefix=/usr \
        --build ${BUILDCOMPILE} \
        --host ${BUILDHOST}
}

compile_xz() {
    echo "[+] compiling xz"
    make ${MAKEOPTS}
}

install_xz() {
    echo "[+] installing xz"
    make DESTDIR="${ROOTDIR}" install
}

build_xz() {
    pushd "${WORKDIR}/xz-${XZ_VERSION}"

    prepare_xz
    compile_xz
    install_xz

    popd
}

registrar_xz() {
    DOWNLOADERS+=(download_xz)
    EXTRACTORS+=(extract_xz)
}

registrar_xz
