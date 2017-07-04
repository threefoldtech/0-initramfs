CORES_VERSION="master"
G8UFS_VERSION="master"

prepare_cores() {
    echo "[+] loading source code: core0"
    go get -d -v github.com/zero-os/0-core/core0

    echo "[+] loading source code: coreX"
    go get -d -v github.com/zero-os/0-core/coreX

    echo "[+] loading source code: g8ufs"
    go get -d -v github.com/zero-os/0-fs

    echo "[+] loading soruce code: ztid"
    go get -d -v github.com/zero-os/ztid

    echo "[+] ensure core0 to branch: ${CORES_VERSION}"
    pushd $GOPATH/src/github.com/zero-os/0-core
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "${CORES_VERSION}" ]; then
        git fetch origin "${CORES_VERSION}:${CORES_VERSION}"
        git checkout "${CORES_VERSION}"
    fi

    git pull origin "${CORES_VERSION}"
    popd

    echo "[+] ensure g8ufs to branch: ${G8UFS_VERSION}"
    pushd $GOPATH/src/github.com/zero-os/0-fs
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
    pushd 0-core
    make
    popd

    echo "[+] compiling 0-fs"
    pushd 0-fs
    make
    popd

    echo "[+] compiling ztid"
    pushd ztid
    go build
    popd
}

install_cores() {
    echo "[+] copying binaries"
    pushd 0-core
    cp -a bin/* "${ROOTDIR}/sbin/"
    cp -a tools/* "${ROOTDIR}/usr/bin/"

    echo "	[+] installing configuration"
    mkdir -p "${ROOTDIR}/etc/zero-os/conf"
    cp -a core0/conf/* "${ROOTDIR}"/etc/zero-os/conf/
    rm -f "${ROOTDIR}"/etc/zero-os/conf/README.md
    popd

    pushd 0-fs
    cp -a g8ufs "${ROOTDIR}/sbin/"
    popd

    pushd ztid
    cp -a ztid "${ROOTDIR}/sbin/"
    popd

    pushd "${ROOTDIR}/sbin"
    ln -sf corectl reboot
    ln -sf corectl poweroff
    popd
}

build_cores() {
    # We need to prepare first (download code)
    prepare_cores
    pushd $GOPATH/src/github.com/zero-os

    compile_cores
    install_cores

    popd
}
