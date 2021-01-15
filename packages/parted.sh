PARTED_VERSION="3.3"
PARTED_CHECKSUM="090655d05f3c471aa8e15a27536889ec"
PARTED_LINK="http://ftp.gnu.org/gnu/parted/parted-${PARTED_VERSION}.tar.xz"

download_parted() {
    download_file $PARTED_LINK $PARTED_CHECKSUM
}

extract_parted() {
    if [ ! -d "parted-${PARTED_VERSION}" ]; then
        echo "[+] extracting: parted-${PARTED_VERSION}"
        tar -xf ${DISTFILES}/parted-${PARTED_VERSION}.tar.xz -C .
    fi
}

prepare_parted() {
    echo "[+] configuring parted"
    ./configure --prefix="${ROOTDIR}"/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --without-readline \
        --disable-device-mapper
}

compile_parted() {
    make LDFLAGS="-L${ROOTDIR}/lib -lblkid -luuid" ${MAKEOPTS}
}

install_parted() {
    make install
}

build_parted() {
    pushd "${WORKDIR}/parted-${PARTED_VERSION}"

    prepare_parted
    compile_parted
    install_parted

    popd
}

registrar_parted() {
    DOWNLOADERS+=(download_parted)
    EXTRACTORS+=(extract_parted)
}

registrar_parted
