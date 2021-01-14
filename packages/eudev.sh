EUDEV_VERSION="3.2.9"
EUDEV_CHECKSUM="e575ef39f66be11a6a5b6c8a169d3c7e"
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

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --enable-blkid \
        --enable-kmod \
        --disable-selinux \
        --disable-static \
        --disable-rule-generator \
        --exec-prefix= \
        --with-rootprefix= \
        --with-sysroot=${ROOTDIR} \
        --bindir=/bin
}

compile_eudev() {
    echo "[+] compiling eudev"
    make V=1 ${MAKEOPTS}

    # patching network rules for @delandtj
    sed -i /NET_NAME_ONBOARD/d rules/80-net-name-slot.rules
}

install_eudev() {
    echo "[+] installing eudev"
    make DESTDIR="${ROOTDIR}" install

    echo "[+] compiling original hwdb"
    # ${ROOTDIR}/bin/udevadm hwdb --update --root=${ROOTDIR}

    unset LDFLAGS
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
