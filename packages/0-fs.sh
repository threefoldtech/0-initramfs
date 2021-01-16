ZFS_VERSION="2.0.6"
ZFS_CHECKSUM="06368fd114642373c1bb024bad2d419e"
ZFS_LINK="https://github.com/threefoldtech/0-fs/archive/v${ZFS_VERSION}.tar.gz"

download_zfs() {
    download_file $ZFS_LINK $ZFS_CHECKSUM 0-fs-${ZFS_VERSION}.tar.gz
}

extract_zfs() {
    if [ ! -d "0-fs-${ZFS_VERSION}" ]; then
        echo "[+] extracting: 0-fs-${ZFS_VERSION}"
        tar -xf ${DISTFILES}/0-fs-${ZFS_VERSION}.tar.gz -C .
    fi
}

prepare_zfs() {
    echo "[+] preparing 0-fs"
}

compile_zfs() {
    echo "[+] compiling 0-fs"
    pushd cmd
    goldflags="-w -s"
    GO111MODULE=on go build -ldflags "${goldflags}" -o ../g8ufs
    popd
}

install_zfs() {
    echo "[+] copying binaries"
    # the binary name is still called g8ufs
    cp -av g8ufs "${ROOTDIR}/sbin/"
}

build_zfs() {
    pushd "${WORKDIR}/0-fs-${ZFS_VERSION}"

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
