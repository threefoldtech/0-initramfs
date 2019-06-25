EUDEV_VERSION="3.2.8"
EUDEV_CHECKSUM="3b856ff7171474c9866ad34b3ea4daac"
EUDEV_LINK="https://github.com/gentoo/eudev/archive/v${EUDEV_VERSION}.tar.gz"

download_eudev() {
    download_file $EUDEV_LINK $EUDEV_CHECKSUM eudev-${EUDEV_VERSION}.tar.gz
}

extract_eudev() {
    if [ ! -d "eudev-${EUDEV_VERSION}" ]; then
        echo "[+] extracting: eudev-${EUDEV_VERSION}"
        tar -xf ${DISTFILES}/eudev-${EUDEV_VERSION}.tar.gz -C .
    fi
}

prepare_eudev() {
    echo "[+] preparing eudev"
    ./autogen.sh
    ./configure --prefix=/ --enable-kmod --enable-blkid
}

compile_eudev() {
    echo "[+] compiling eudev"
    make ${MAKEOPTS}

    # patching network rules for @delandtj
    sed -i /NET_NAME_ONBOARD/d rules/80-net-name-slot.rules
}

install_eudev() {
    echo "[+] installing eudev"
    make DESTDIR="${ROOTDIR}" install
}

build_eudev() {
    pushd "${WORKDIR}/eudev-${EUDEV_VERSION}"

    prepare_eudev
    compile_eudev
    install_eudev

    popd
}

registrar_eudev() {
    DOWNLOADERS+=(download_eudev)
    EXTRACTORS+=(extract_eudev)
}

registrar_eudev
