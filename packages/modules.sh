MODULES_VERSION="0.4.3"
MODULES_CHECKSUM="99fd8573891897543db73673b6f2016d"
MODULES_LINK="https://github.com/threefoldtech/zos/archive/v${MODULES_VERSION}.tar.gz"

download_modules() {
    download_file $MODULES_LINK $MODULES_CHECKSUM zos-${MODULES_VERSION}.tar.gz
}

extract_modules() {
    if [ ! -d "zos-${MODULES_VERSION}" ]; then
        echo "[+] extracting: zos-${MODULES_VERSION}"
        tar -xf ${DISTFILES}/zos-${MODULES_VERSION}.tar.gz -C .
    fi
}

prepare_modules() {
    echo "[+] prepare modules"
}

compile_modules() {
    echo "[+] building zos bootstrap"

    export GO111MODULE=on

    pushd cmds
    make internet
    popd

    pushd bootstrap/bootstrap
    cargo build --release --target=arm-unknown-linux-gnueabi --features vendored
    popd

}

install_modules() {
    echo "[+] installing zos bootstrap"
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
    pushd ${WORKDIR}/zos-${MODULES_VERSION}

    prepare_modules
    compile_modules
    install_modules

    popd
}

registrar_modules() {
    DOWNLOADERS+=(download_modules)
    EXTRACTORS+=(extract_modules)
}

registrar_modules
