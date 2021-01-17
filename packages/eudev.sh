EUDEV_PKGNAME="eudev"
EUDEV_VERSION="3.2.9"
EUDEV_CHECKSUM="e575ef39f66be11a6a5b6c8a169d3c7e"
EUDEV_LINK="https://github.com/gentoo/eudev/archive/v${EUDEV_VERSION}.tar.gz"

download_eudev() {
    download_file $EUDEV_LINK $EUDEV_CHECKSUM ${EUDEV_PKGNAME}-${EUDEV_VERSION}.tar.gz
}

extract_eudev() {
    if [ ! -d "${EUDEV_PKGNAME}-${EUDEV_VERSION}" ]; then
        progress "extracting: ${EUDEV_PKGNAME}-${EUDEV_VERSION}"
        tar -xf ${DISTFILES}/${EUDEV_PKGNAME}-${EUDEV_VERSION}.tar.gz -C .
    fi
}

prepare_eudev() {
    progress "preparing: ${EUDEV_PKGNAME}"

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
    progress "compiling: ${EUDEV_PKGNAME}"

    make V=1 ${MAKEOPTS}

    # patching network rules for @delandtj
    sed -i /NET_NAME_ONBOARD/d rules/80-net-name-slot.rules
}

install_eudev() {
    progress "installing: ${EUDEV_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install

    progress "compiling: original hwdb"
    # ${ROOTDIR}/bin/udevadm hwdb --update --root=${ROOTDIR}
}

build_eudev() {
    pushd "${WORKDIR}/${EUDEV_PKGNAME}-${EUDEV_VERSION}"

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
