ZFS_VERSION="0.2.6"
ZFS_HASH="8d576939d75b12613abdfc1bd18204f6"
ZFS_BINARY="https://github.com/threefoldtech/rfs/releases/download/v${ZFS_VERSION}/rfs"

download_zfs() {
    download_file ${ZFS_BINARY} ${ZFS_HASH} "rfs-${ZFS_VERSION}"
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
