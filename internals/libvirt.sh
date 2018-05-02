LIBVIRT_VERSION="1.3.5"
LIBVIRT_CHECKSUM="f9dc1e63d559eca50ae0ee798a4c6c6d"
LIBVIRT_LINK="http://libvirt.org/sources/libvirt-${LIBVIRT_VERSION}.tar.gz"

download_libvirt() {
    download_file $LIBVIRT_LINK $LIBVIRT_CHECKSUM
}

# dev-libs/yajl

extract_libvirt() {
    if [ ! -d "libvirt-${LIBVIRT_VERSION}" ]; then
        echo "[+] extracting: libvirt-${LIBVIRT_VERSION}"
        tar -xf ${DISTFILES}/libvirt-${LIBVIRT_VERSION}.tar.gz -C .
    fi
}

prepare_libvirt() {
    export BLKID_CFLAGS="-I${ROOTDIR}/usr/include"
    export BLKID_LIBS="-L${ROOTDIR}/usr/lib -lblkid"
    export PKG_CONFIG_PATH="${ROOTDIR}/usr/lib/pkgconfig"

    echo "[+] preparing libvirt"
    ./configure --prefix=/ \
        --with-qemu \
        --with-fuse \
        --with-yajl \
        --with-init-script=none \
        --with-sysctl=no \
        --without-apparmor \
        --without-avahi \
        --without-dbus \
        --without-glusterfs \
        --without-hal \
        --without-selinux \
        --without-selinux-mount \
        --without-systemd-daemon \
        --without-xen \
        --without-openvz \
        --without-vmware \
        --without-phyp \
        --without-xenapi \
        --without-libxl \
        --without-vbox \
        --without-lxc \
        --without-esx \
        --without-hyperv \
        --without-vz \
        --without-uml \
        --without-bhyve \
        --without-firewalld \
        --without-secdriver-selinux \
        --without-secdriver-apparmor \
        --without-apparmor-profiles \
        --without-storage-iscsi \
        --without-storage-scsi \
        --without-storage-rbd \
        --without-storage-sheepdog \
        --without-storage-gluster \
        --without-storage-zfs \
        --without-wireshark-dissector \
        --without-pm-utils \
        --without-firewalld
}

compile_libvirt() {
    echo "[+] compiling libvirt"
    make ${MAKEOPTS}
}

install_libvirt() {
    echo "[+] installing libvirt"
    make DESTDIR="${ROOTDIR}" install

    unset PKG_CONFIG_PATH
    unset BLKID_CFLAGS
    unset BLKID_LIBS
}

build_libvirt() {
    pushd "${WORKDIR}/libvirt-${LIBVIRT_VERSION}"

    prepare_libvirt
    compile_libvirt
    install_libvirt

    popd
}

registrar_libvirt() {
    DOWNLOADERS+=(download_libvirt)
    EXTRACTORS+=(extract_libvirt)
}

registrar_libvirt
