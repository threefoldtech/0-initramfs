SEEKTIME_REPOSITORY="https://github.com/zero-os/seektime"
SEEKTIME_BRANCH="master"

download_seektime() {
    download_git $SEEKTIME_REPOSITORY $SEEKTIME_BRANCH
}

extract_seektime() {
    event "refreshing" "seektime-${SEEKTIME_BRANCH}"
    rm -rf ./seektime-${SEEKTIME_BRANCH}
    cp -a ${DISTFILES}/seektime ./seektime-${SEEKTIME_BRANCH}
}

prepare_seektime() {
    echo "[+] preparing seektime"
    make mrproper
}

compile_seektime() {
    make ${MAKEOPTS}
}

install_seektime() {
    cp -avL seektime "${ROOTDIR}/usr/bin/"
}

build_seektime() {
    pushd "${WORKDIR}/seektime-${SEEKTIME_BRANCH}"

    prepare_seektime
    compile_seektime
    install_seektime

    popd
}

registrar_seektime() {
    DOWNLOADERS+=(download_seektime)
    EXTRACTORS+=(extract_seektime)
}

registrar_seektime
