ZINIT_VERSION="master"
G8UFS_VERSION="development"

github_force() {
    if [ -d $3 ]; then
        pushd $3
        git fetch
        git checkout $2
        git pull origin $2
        popd

    else
        git clone https://github.com/$1 $3
        pushd $3
        git checkout $2
        popd
    fi
}

prepare_zinit() {
    echo "[+] loading source code: zinit"
    github_force threefoldtech/zinit $ZINIT_VERSION zinit

    echo "[+] loading source code: 0-fs"
    github_force threefoldtech/0-fs $G8UFS_VERSION 0-fs

    echo "[+] loading soruce code: ztid"
    github_force threefoldtech/ztid master ztid

    pushd ztid
    go get -v ./...
    popd
}

compile_zinit() {
    echo "[+] compiling zinit"
    pushd zinit
    make release
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

install_zinit() {
    echo "[+] copying binaries"
    pushd zinit
    cp -a target/release/zinit "${ROOTDIR}/sbin/"
    # cp -a tools/* "${ROOTDIR}/usr/bin/"

    # echo "[+] installing configuration"
    # mkdir -p "${ROOTDIR}/etc/zero-os/conf"
    # cp -a apps/core0/conf/* "${ROOTDIR}"/etc/zero-os/conf/
    # rm -f "${ROOTDIR}"/etc/zero-os/conf/README.md
    popd

    pushd 0-fs
    cp -a g8ufs "${ROOTDIR}/sbin/"
    popd

    pushd ztid
    cp -a ztid "${ROOTDIR}/sbin/"
    popd

    pushd "${ROOTDIR}/sbin"
    # ln -sf corectl reboot
    # ln -sf corectl poweroff
    popd
}

build_zinit() {
    mkdir -p $GOPATH/src/github.com/threefoldtech
    pushd $GOPATH/src/github.com/threefoldtech

    prepare_zinit
    compile_zinit
    install_zinit

    popd
}
