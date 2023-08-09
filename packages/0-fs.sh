ZFS_VERSION="1.1.1"
ZFS_HASH="974b8dc45ae9c1b00238a79b0f4fc9de"
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
