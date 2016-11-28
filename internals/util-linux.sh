LINUXUTILS_VERSION="2.29"
LINUXUTILS_CHECKSUM="07b6845f48a421ad5844aa9d58edb837"
LINUXUTILS_LINK="https://www.kernel.org/pub/linux/utils/util-linux/v2.29/util-linux-${LINUXUTILS_VERSION}.tar.xz"

download_linuxutil() {
    download_file $LINUXUTILS_LINK $LINUXUTILS_CHECKSUM
}

extract_linuxutil() {
    if [ ! -d "util-linux-${LINUXUTILS_VERSION}" ]; then
        echo "[+] extracting: util-linux-${LINUXUTILS_VERSION}"
        tar -xf ${DISTFILES}/util-linux-${LINUXUTILS_VERSION}.tar.xz -C .
    fi
}

prepare_linuxutil() {
    echo "[+] configuring util-linux"
    ./configure --prefix "${ROOTDIR}"/usr \
        --disable-libfdisk \
        --disable-mount \
        --disable-zramctl \
        --disable-mountpoint \
        --disable-eject \
        --disable-lslogins \
        --disable-setpriv \
        --disable-agetty \
        --disable-cramfs \
        --disable-bfs \
        --disable-minix \
        --disable-fdformat \
        --disable-wdctl \
        --disable-cal \
        --disable-logger \
        --disable-switch_root \
        --disable-pivot_root \
        --disable-ipcrm \
        --disable-ipcs \
        --disable-kill \
        --disable-last \
        --disable-utmpdump \
        --disable-mesg \
        --disable-raw \
        --disable-rename \
        --disable-login \
        --disable-nologin \
        --disable-sulogin \
        --disable-su \
        --disable-runuser \
        --disable-ul \
        --disable-more \
        --disable-wall \
        --disable-pylibmount \
        --disable-bash-completion \
        --without-python
}

compile_linuxutil() {
    make ${MAKEOPTS}
}

install_linuxutil() {
    make install
}

build_linuxutil() {
    pushd "${WORKDIR}/util-linux-${LINUXUTILS_VERSION}"

    prepare_linuxutil
    compile_linuxutil
    install_linuxutil

    popd
}
