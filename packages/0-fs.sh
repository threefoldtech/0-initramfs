ZFS_PKGNAME="0-fs"
ZFS_VERSION="2.0.6"
ZFS_CHECKSUM="06368fd114642373c1bb024bad2d419e"
ZFS_LINK="https://github.com/threefoldtech/0-fs/archive/v${ZFS_VERSION}.tar.gz"

download_zfs() {
    download_file $ZFS_LINK $ZFS_CHECKSUM 0-fs-${ZFS_VERSION}.tar.gz
}

extract_zfs() {
    if [ ! -d "${ZFS_PKGNAME}-${ZFS_VERSION}" ]; then
        progress "extracting: ${ZFS_PKGNAME}-${ZFS_VERSION}"
        tar -xf ${DISTFILES}/${ZFS_PKGNAME}-${ZFS_VERSION}.tar.gz -C .
    fi
}

prepare_zfs() {
    progress "preparing: ${ZFS_PKGNAME}"
}

compile_zfs() {
    progress "compiling: ${ZFS_PKGNAME}"

    pushd cmd
    zfs_goldflags="-w -s"
    GO111MODULE=on CGO_ENABLED=1 go build -x -v -ldflags "${zfs_goldflags}" -o ../g8ufs
    popd
}

install_zfs() {
    progress "installing: ${ZFS_PKGNAME}"

    # the binary name is still called g8ufs
    cp -av g8ufs "${ROOTDIR}/sbin/"
}

build_zfs() {
    pushd "${WORKDIR}/${ZFS_PKGNAME}-${ZFS_VERSION}"

    prepare_zfs
    compile_zfs
    install_zfs

    popd
}

registrar_zfs() {
    DOWNLOADERS+=(download_zfs)
    EXTRACTORS+=(extract_zfs)
}

registrar_zfs
