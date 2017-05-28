CORES_VERSION="master"
G8UFS_VERSION="master"

prepare_cores() {
    echo "[+] loading source code: core0"
    go get -d -v github.com/Zero-OS/0-Core/core0

    echo "[+] loading source code: coreX"
    go get -d -v github.com/Zero-OS/0-Core/coreX

    echo "[+] loading source code: g8ufs"
    go get -d -v github.com/Zero-OS/0-FS

    echo "[+] ensure core0 to branch: ${CORES_VERSION}"
    pushd $GOPATH/src/github.com/Zero-OS/0-Core
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "${CORES_VERSION}" ]; then
        git fetch origin "${CORES_VERSION}:${CORES_VERSION}"
        git checkout "${CORES_VERSION}"
    fi

    git pull origin "${CORES_VERSION}"
    popd

    echo "[+] ensure g8ufs to branch: ${G8UFS_VERSION}"
    pushd $GOPATH/src/github.com/Zero-OS/0-FS
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "${G8UFS_VERSION}" ]; then
        git fetch origin "${G8UFS_VERSION}:${G8UFS_VERSION}"
        git checkout "${G8UFS_VERSION}"
    fi

    git pull origin "${G8UFS_VERSION}"
    popd
}

compile_cores() {
    echo "[+] compiling coreX and core0"
    make

    echo "[+] compiling 0-FS"
    pushd ../0-FS
    make
    popd
}

install_cores() {
    echo "[+] copying binaries"
    cp -a bin/* "${ROOTDIR}/sbin/"
    cp -a tools/* "${ROOTDIR}/usr/bin/"
    cp -a ../0-FS/g8ufs "${ROOTDIR}/sbin/"
    pushd "${ROOTDIR}/sbin"
    ln -sf corectl reboot
    ln -sf corectl poweroff
    popd

    echo "[+] installing configuration"
    mkdir -p "${ROOTDIR}/etc/g8os/conf"
    cp -a core0/conf/* "${ROOTDIR}"/etc/g8os/conf/
    rm -f "${ROOTDIR}"/etc/g8os/conf/README.md
}

build_cores() {
    # We need to prepare first (download code)
    prepare_cores
    pushd $GOPATH/src/github.com/Zero-OS/0-Core

    compile_cores
    install_cores

    popd
}
