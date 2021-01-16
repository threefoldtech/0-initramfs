ZINIT_REPOSITORY="https://github.com/threefoldtech/zinit"
ZINIT_VERSION="master"

download_zinit() {
    download_git ${ZINIT_REPOSITORY} ${ZINIT_VERSION}
}

extract_zinit() {
    event "refreshing" "zinit-${ZINIT_VERSION}"
    rm -rf ./zinit-${ZINIT_VERSION}
    cp -a ${DISTFILES}/zinit ./zinit-${ZINIT_VERSION}
}

prepare_zinit() {
    echo "[+] loading source code: zinit"
}

compile_zinit() {
    echo "[+] compiling zinit"
    # cargo build --release --target=x86_64-unknown-linux-musl

    export CC_arm_unknown_linux_gnueabi="${BUILDHOST}-gcc"
    cargo build --release --target=${BUILDRUST}
    unset CC_arm_unknown_linux_gnueabi
}

install_zinit() {
    echo "[+] copying binaries"
    # cp -a target/x86_64-unknown-linux-musl/release/zinit "${ROOTDIR}/sbin/"
    cp -a target/arm-unknown-linux-gnueabi/release/zinit "${ROOTDIR}/sbin/"
}

build_zinit() {
    pushd "${WORKDIR}/zinit-${ZINIT_VERSION}"

    prepare_zinit
    compile_zinit
    install_zinit

    popd
}

registrar_zinit() {
    DOWNLOADERS+=(download_zinit)
    EXTRACTORS+=(extract_zinit)
}

registrar_zinit

