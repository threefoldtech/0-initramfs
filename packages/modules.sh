MODULES_PKGNAME="zos"
MODULES_VERSION="0.4.3"
MODULES_CHECKSUM="99fd8573891897543db73673b6f2016d"
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

    pushd cmds
    make internet
    popd

    pushd bootstrap/bootstrap
    cargo build --release --target=arm-unknown-linux-gnueabi --features vendored
    popd

}

install_modules() {
    progress "installing: ${MODULES_VERSION}"

    mkdir -p ${ROOTDIR}/etc/zinit/
    mkdir -p ${ROOTDIR}/bin
    mkdir -p ${ROOTDIR}/sbin

    # install interent
    cp bin/internet ${ROOTDIR}/bin

    # install bootstrap
    cp -a bootstrap/etc ${ROOTDIR}
    cp bootstrap/bootstrap/target/arm-unknown-linux-gnueabi/release/bootstrap ${ROOTDIR}/sbin/
}

build_modules() {
    pushd ${WORKDIR}/${MODULES_PKGNAME}-${MODULES_VERSION}

    compile_modules
    install_modules

    popd
}

registrar_modules() {
    DOWNLOADERS+=(download_modules)
    EXTRACTORS+=(extract_modules)
}

registrar_modules
