TF_HOME="${GOPATH}/src/github.com/threefoldtech"

ZFS_REPOSITORY="https://github.com/threefoldtech/0-fs"
ZFS_VERSION="development"

download_zfs() {
    download_git ${ZFS_REPOSITORY} ${ZFS_VERSION}
}

extract_zfs() {
    event "refreshing ZFS-${ZFS_VERSION}"
    mkdir -p ${TF_HOME}
    rm -rf ${TF_HOME}/0-fs
    cp -a ${DISTFILES}/0-fs ${TF_HOME}/
}

prepare_zfs() {
    echo "[+] loading source code: 0-fs"
}

compile_zfs() {
    echo "[+] compiling 0-fs"
    pushd 0-fs
    make
    popd
}

install_zfs() {
    echo "[+] copying binaries"
    pushd 0-fs
    # the binary name is still called g8ufs
    cp -a g8ufs "${ROOTDIR}/sbin/"
    popd
}

build_zfs() {
    mkdir -p $TF_HOME
    pushd $TF_HOME

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

