BCACHE_REPOSITORY="https://github.com/koverstreet/bcache-tools"
BCACHE_BRANCH="master"

download_bcache() {
    download_git $BCACHE_REPOSITORY $BCACHE_BRANCH
}

extract_bcache() {
    event "refreshing" "bcache-tools-${BCACHE_BRANCH}"
    rm -rf ./bcache-tools-${BCACHE_BRANCH}
    cp -a ${DISTFILES}/bcache-tools ./bcache-tools-${BCACHE_BRANCH}
}

prepare_bcache() {
    echo "[+] preparing bcache-tools"

    if [ ! -f .patched_bcache-tools-gcc5.patch ]; then
        echo "[+] patching bcache-tools"
        patch -p1 < ${PATCHESDIR}/bcache-tools-gcc5.patch
        touch .patched_bcache-tools-gcc5.patch
    fi
}

compile_bcache() {
    make ${MAKEOPTS}
}

install_bcache() {
    make DESTDIR=${ROOTDIR} install
}

build_bcache() {
    pushd "${WORKDIR}/bcache-tools-${BCACHE_BRANCH}"

    prepare_bcache
    compile_bcache
    install_bcache

    popd
}

registrar_bcache() {
    DOWNLOADERS+=(download_bcache)
    EXTRACTORS+=(extract_bcache)
}

registrar_bcache

