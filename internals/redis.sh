REDIS_VERSION="4.0.8"
REDIS_CHECKSUM="c75b11e4177e153e4dc1d8dd3a6174e4"
REDIS_LINK="http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"

download_redis() {
    download_file $REDIS_LINK $REDIS_CHECKSUM
}

extract_redis() {
    if [ ! -d "redis-${REDIS_VERSION}" ]; then
        echo "[+] extracting: redis-${REDIS_VERSION}"
        tar -xf ${DISTFILES}/redis-${REDIS_VERSION}.tar.gz -C .
    fi
}

prepare_redis() {
    echo "[+] preparing redis"
    make distclean
}

compile_redis() {
    make ${MAKEOPTS}
}

install_redis() {
    cp -avL src/redis-server "${ROOTDIR}/usr/bin/"
}

build_redis() {
    pushd "${WORKDIR}/redis-${REDIS_VERSION}"

    prepare_redis
    compile_redis
    install_redis

    popd
}

registrar_redis() {
    DOWNLOADERS+=(download_redis)
    EXTRACTORS+=(extract_redis)
}

registrar_redis
