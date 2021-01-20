MODULES_PKGNAME="zos"
MODULES_VERSION="0.4.8"
MODULES_CHECKSUM="4dcfb5e28fcc90b632da41da428c3f32"
MODULES_LINK="https://github.com/threefoldtech/zos/archive/v${MODULES_VERSION}.tar.gz"

download_modules() {
    download_file $MODULES_LINK $MODULES_CHECKSUM ${MODULES_PKGNAME}-${MODULES_VERSION}.tar.gz
}

extract_modules() {
    if [ ! -d "${MODULES_PKGNAME}-${MODULES_VERSION}" ]; then
        progress "extracting: ${MODULES_PKGNAME}-${MODULES_VERSION}"
        tar -xf ${DISTFILES}/${MODULES_PKGNAME}-${MODULES_VERSION}.tar.gz -C .
    fi
}

compile_modules() {
    progress "compiling: ${MODULES_PKGNAME}"

    export GO111MODULE=on

    echo "[+] patching Makefile"
    sed -i /strip/d cmds/Makefile

    pushd cmds
    # make internet
    GO111MODULE=on CGO_ENABLED=1 make
    popd

    pushd bootstrap/bootstrap
    cargo build --release --target=arm-unknown-linux-gnueabi --features vendored
    popd
}

install_modules() {
    progress "installing: ${MODULES_PKGNAME}"

    mkdir -p ${ROOTDIR}/etc/zinit/
    mkdir -p ${ROOTDIR}/bin
    mkdir -p ${ROOTDIR}/sbin

    # install interent
    cp bin/internet ${ROOTDIR}/bin/
    cp bin/identityd ${ROOTDIR}/bin/  ## FIXME

    # install bootstrap
    cp -a bootstrap/etc ${ROOTDIR}
    cp bootstrap/bootstrap/target/arm-unknown-linux-gnueabi/release/bootstrap ${ROOTDIR}/sbin/

    # install debug service
    cp qemu/overlay/etc/zinit/bootstrap.yaml ${ROOTDIR}/etc/zinit/
    # cp qemu/overlay/etc/zinit/identityd.yaml ${ROOTDIR}/etc/zinit/
    # cp qemu/overlay/etc/zinit/redis.yaml ${ROOTDIR}/etc/zinit/
}

install_modules_runtime() {
    progress "installing: ${MODULES_PKGNAME}"

    mkdir -p ${RUNDIR}/etc/zinit/
    mkdir -p ${RUNDIR}/usr/bin

    # install service
    cp -a etc/* ${RUNDIR}/etc/

    cp -a bin/* ${RUNDIR}/usr/bin/

    # cp qemu/overlay/etc/zinit/bootstrap.yaml ${RUNDIR}/etc/zinit/
    # cp qemu/overlay/etc/zinit/identityd.yaml ${ROOTDIR}/etc/zinit/
    # cp qemu/overlay/etc/zinit/redis.yaml ${RUNDIR}/etc/zinit/
}

build_modules() {
    pushd ${WORKDIR}/${MODULES_PKGNAME}-${MODULES_VERSION}

    compile_modules
    install_modules

    popd
}

build_modules_runtime() {
    pushd ${WORKDIR}/${MODULES_PKGNAME}-${MODULES_VERSION}

    compile_modules
    install_modules_runtime

    popd
}

registrar_modules() {
    DOWNLOADERS+=(download_modules)
    EXTRACTORS+=(extract_modules)
}

registrar_modules
