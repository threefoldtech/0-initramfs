ROCKSDB_VERSION="2e64f450dc73104f3ba56651e82abf35ef59f74e"
ROCKSDB_CHECKSUM="c6f5e96755d5999d5a9d69ca8cc1e6a2"
ROCKSDB_LINK="https://github.com/facebook/rocksdb/archive/${ROCKSDB_VERSION}.tar.gz"

download_gorocksdb() {
    download_file $ROCKSDB_LINK $ROCKSDB_CHECKSUM rocksdb-${ROCKSDB_VERSION}.tar.gz
}

extract_gorocksdb() {
    if [ ! -d "rocksdb-${ROCKSDB_VERSION}" ]; then
        echo "[+] extracting: rocksdb-${ROCKSDB_VERSION}"
        tar -xf ${DISTFILES}/rocksdb-${ROCKSDB_VERSION}.tar.gz -C .
    fi
}

prepare_rocksdb() {
    echo "[+] preparing rocksdb"
}

compile_rocksdb() {
    echo "[+] compiling rocksdb"
    PORTABLE=1 make ${MAKEOPTS} shared_lib
}

install_rocksdb() {
    echo "[+] installing rocksdb"
    cp -a librocksdb.so* "${ROOTDIR}"/usr/lib/
}

prepare_gorocksdb() {
    echo "[+] preparing gorocksdb"

    CGO_CFLAGS="-I${WORKDIR}/rocksdb-${ROCKSDB_VERSION}/include" \
    CGO_LDFLAGS="-L${WORKDIR}/rocksdb-${ROCKSDB_VERSION} -lrocksdb -lstdc++ -lm -lz -lbz2 -lsnappy -llz4" \
      go get -v github.com/tecbot/gorocksdb
}

compile_gorocksdb() {
    echo "[+] compiling gorocksdb"
    # make ${MAKEOPTS}
}

install_gorocksdb() {
    echo "[+] installing gorocksdb"
}

build_gorocksdb() {
    pushd "${WORKDIR}/rocksdb-${ROCKSDB_VERSION}"

    prepare_rocksdb
    compile_rocksdb
    install_rocksdb

    # we stays on rocksdb directory
    # it's used for building gorocksdb
    prepare_gorocksdb
    compile_gorocksdb
    install_gorocksdb

    popd
}
