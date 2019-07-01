TF_HOME="${GOPATH}/src/github.com/threefoldtech"

G8UFS_REPOSITORY="https://github.com/threefoldtech/0-fs"
G8UFS_VERSION="development"

download_zfs() {
    download_git ${G8UFS_REPOSITORY} ${G8UFS_VERSION}
}

extract_zfs() {
    event "refreshing G8UFS-${G8UFS_VERSION}"
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

