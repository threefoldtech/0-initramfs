REDIS_VERSION="3.2.5"
REDIS_CHECKSUM="d3d2b4dd4b2a3e07ee6f63c526b66b08"
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
    return
}

compile_redis() {
    make ${MAKEOPTS}
}

install_redis() {
    cp -a src/redis-server "${ROOTDIR}"/usr/bin/
}

build_redis() {
    pushd "${WORKDIR}/redis-${REDIS_VERSION}"

    prepare_redis
    compile_redis
    install_redis

    popd
}
