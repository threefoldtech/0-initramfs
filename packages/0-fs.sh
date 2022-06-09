ZFS_VERSION="0.2.6"
ZFS_HASH="0eb065fbb26a838d1bf6e534a9885c16"
ZFS_BINARY="https://github.com/threefoldtech/rfs/releases/download/v${ZFS_VERSION}/rfs"

download_zfs() {
    download_file ${ZFS_BINARY} ${ZFS_HASH} "zinit-${ZFS_VERSION}"
}

install_zfs() {
    echo "[+] copying binaries"
    filepath="${DISTFILES}/rfs-${ZFS_VERSION}"
    chmod +x ${filepath}
    # we keep the legacy name g8ufs
    cp -a "${filepath}" "${ROOTDIR}/sbin/g8ufs"
}

build_zfs() {
    install_zfs
}

registrar_zfs() {
    DOWNLOADERS+=(download_zfs)
}

registrar_zfs
