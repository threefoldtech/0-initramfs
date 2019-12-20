LINUXUTILS_VERSION="2.34"
LINUXUTILS_CHECKSUM="a78cbeaed9c39094b96a48ba8f891d50"
LINUXUTILS_LINK="https://www.kernel.org/pub/linux/utils/util-linux/v${LINUXUTILS_VERSION}/util-linux-${LINUXUTILS_VERSION}.tar.xz"

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

    # disable tool one by one
    # --disable-all-progs is too aggressive and
    # don't let possibility to re-enable some specific
    # default software
    ./configure --prefix /usr \
        --disable-libfdisk \
        --disable-partx \
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
        --disable-schedutils \
        --disable-fsck \
        --disable-minix \
        --disable-rename \
        --disable-bash-completion \
        --disable-fdformat \
        --without-python
}

compile_linuxutil() {
    make ${MAKEOPTS}
}

install_linuxutil() {
    make DESTDIR="${ROOTDIR}" install

    # remove tools not needed (busybox does it)
    rm -f "${ROOTDIR}/usr/sbin/swapoff"
    rm -f "${ROOTDIR}/usr/sbin/swapon"
    rm -f "${ROOTDIR}/usr/sbin/swaplabel"
    rm -f "${ROOTDIR}/usr/sbin/readprofile"
    rm -f "${ROOTDIR}/usr/sbin/rtcwake"
    rm -f "${ROOTDIR}/usr/sbin/ldattach"
    rm -f "${ROOTDIR}/usr/sbin/ctrlaltdel"

    rm -f "${ROOTDIR}/usr/bin/whereis"

    rm -f "${ROOTDIR}/usr/bin/setarch"
    rm -f "${ROOTDIR}/usr/bin/x86_64"
    rm -f "${ROOTDIR}/usr/bin/i386"
    rm -f "${ROOTDIR}/usr/bin/linux32"
    rm -f "${ROOTDIR}/usr/bin/linux64"

    rm -f "${ROOTDIR}/usr/bin/setterm"
    rm -f "${ROOTDIR}/usr/bin/setsid"
}

build_linuxutil() {
    pushd "${WORKDIR}/util-linux-${LINUXUTILS_VERSION}"

    prepare_linuxutil
    compile_linuxutil
    install_linuxutil

    popd
}

registrar_linuxutil() {
    DOWNLOADERS+=(download_linuxutil)
    EXTRACTORS+=(extract_linuxutil)
}

registrar_linuxutil
