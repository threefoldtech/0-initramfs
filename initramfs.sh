#!/bin/bash
set -e

# Initramfs Building mode, possible values are: debug, release
BUILDMODE="debug"

# You need to use absolutes path
DISTFILES="${PWD}/archives"
WORKDIR="${PWD}/staging"
CONFDIR="${PWD}/config"
ROOTDIR="${PWD}/root"
TMPDIR="${PWD}/tmp"
PKGDIR="${PWD}/packages"
EXTENDIR="${PWD}/extensions"
PATCHESDIR="${PWD}/patches"
TOOLSDIR="${PWD}/tools"

# musl subsystem
MUSLWORKDIR="${PWD}/staging/musl"
MUSLROOTDIR="${PWD}/staging/musl/root"

# Download mirror repository
MIRRORSRC="https://download.grid.tf/initramfs-mirror/"

# By default, we compile with (number of cpu threads + 1)
# you can changes this to reduce computer load
JOBS=$(($(grep -c 'bogomips' /proc/cpuinfo) + 1))
MAKEOPTS="-j ${JOBS}"

#
# Flags
#
OPTS=$(getopt -o adbtckMeolmnzrh --long all,download,busybox,tools,cores,kernel,modules,extensions,ork,clean,mrproper,nomirror,compact,release,help -n 'parse-options' -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi

DO_ALL=1
USE_MIRROR=1

if [ "$OPTS" != " --" ] && [ "$OPTS" != " --release --" ]; then
    DO_ALL=0

    DO_DOWNLOAD=0
    DO_BUSYBOX=0
    DO_TOOLS=0
    DO_CORES=0
    DO_KERNEL=0
    DO_KMODULES=0
    DO_EXTENSIONS=0
    DO_CLEAN=0
    DO_MRPROPER=0
    DO_ORK=0
    DO_COMPACT=0

    eval set -- "$OPTS"
fi

while true; do
    case "$1" in
        -a | --all)        DO_ALL=1;            shift ;;
        -d | --download)   DO_DOWNLOAD=1;       shift ;;
        -b | --busybox)    DO_BUSYBOX=1;        shift ;;
        -t | --tools)      DO_TOOLS=1;          shift ;;
        -c | --cores)      DO_CORES=1;          shift ;;
        -k | --kernel)     DO_KERNEL=1;         shift ;;
        -M | --modules)    DO_KMODULES=1;       shift ;;
        -e | --extensions) DO_EXTENSIONS=1;     shift ;;
        -o | --ork)        DO_ORK=1;            shift ;;
        -l | --clean)      DO_CLEAN=1;          shift ;;
        -z | --compact)    DO_COMPACT=1;        shift ;;
        -m | --mrproper)   DO_MRPROPER=1;       shift ;;
        -n | --nomirror)   USE_MIRROR=0;        shift ;;
        -r | --release)    BUILDMODE="release"; shift ;;
        -h | --help)
            echo "Usage:"
            echo " -a --all         do everything (default, like no argument)"
            echo " -d --download    only download and extract archives"
            echo " -b --busybox     only (re)build busybox"
            echo " -t --tools       only (re)build tools (ssl, fuse, ...)"
            echo " -c --cores       only (re)build core0 and coreX"
            echo " -k --kernel      only (re)build kernel (vmlinuz, produce final image)"
            echo " -M --modules     only (re)build kernel modules"
            echo " -e --extensions  only (re)build extensions"
            echo " -o --ork         only (re)build ork protection"
            echo " -n --nomirror    don't use a mirror to download files (use upstream)"
            echo " -l --clean       only clean staging files (extracted sources)"
            echo " -m --mrproper    only remove staging files and clean the root"
            echo " -z --compact     clean staging file when compilation is done (except kernel)"
            echo " -r --release     force a release build"
            echo " -h --help        display this help message"
            exit 1
        shift ;;

        -- ) shift; break ;;
        * ) break ;;
    esac
done

#
# Including sub-system (auto loading the whole directory)
#
modules=0
DOWNLOADERS=()
EXTRACTORS=()

for module in "${PKGDIR}"/*.sh; do
    # loading submodule
    . "${module}"

    modules=$(($modules + 1))
done

#
# Utilities
#
pushd() {
    command pushd "$@" > /dev/null
}

popd() {
    command popd "$@" > /dev/null
}

#
# interface tools
#
green="\033[32;1m"
orange="\033[33;1m"
blue="\033[34;1m"
cyan="\033[36;1m"
white="\033[37;1m"
clean="\033[0m"

success() {
    echo -e "${green}$1${clean}"
}

info() {
    echo -e "${blue}$1${clean}"
}

warning() {
    echo -e "${orange}$1${clean}"
}

event() {
    echo -e "[+] ${blue}$1: ${clean}$2 ${orange}$3${clean}"
}

#
# Check the md5 hash from a file ($1) and compare with $2
#
checksum() {
    checksum=$(md5sum "$1" | awk '{ print $1 }')

    if [ "${checksum}" == "$2" ]; then
        # echo "[+] checksum match"
        return 0
    else
        echo "[-] checksum mismatch"
        return 1
    fi
}

#
# Sanity check
#
prepare() {
    if [ ! -d "${CONFDIR}" ]; then
        echo "[-] confdir (${CONFDIR}) not found"
        exit 1
    fi

    if [ -z $GOPATH ]; then
        echo "[-] gopath not defined"
        exit 1
    fi

    echo "[+] setting up local system"
    echo "[+] building mode: ${BUILDMODE}"
    echo "[+] ${modules} submodules loaded"

    if [ $UID != 0 ]; then
        warning "[-]"
        warning "[-] === WARNING ==="
        warning "[-] initramfs files need to be chown root"
        warning "[-] you need to run this script as root if you want"
        warning "[-] a working root filesystem, you can build it without"
        warning "[-] root privilege but you will hit trouble when running"
        warning "[-] the kernel, you have been warned."
        warning "[-] === WARNING ==="
        warning "[-]"
        sleep 1
    fi

    mkdir -p "${DISTFILES}"
    mkdir -p "${WORKDIR}"
    mkdir -p "${ROOTDIR}"
    mkdir -p "${EXTENDIR}"

    mkdir -p "${ROOTDIR}"/usr/lib
    mkdir -p "${ROOTDIR}"/sbin

    if [ ! -e "${ROOTDIR}"/lib ]; then
        ln -s usr/lib "${ROOTDIR}"/lib
    fi

    if [ ! -e "${ROOTDIR}"/lib64 ]; then
        ln -s usr/lib "${ROOTDIR}"/lib64
    fi

    # prepare musl target
    prepare_musl
}

# Extra musl Subsystem
prepare_musl() {
    echo "[+] setting up musl base system"

    mkdir -p ${MUSLWORKDIR}
    mkdir -p ${MUSLROOTDIR}

    # linking linux source kernel to musl path
    ln -fs /usr/include/linux /usr/include/x86_64-linux-musl/

    # linking some specific headers
    ln -fs /usr/include/asm-generic /usr/include/x86_64-linux-musl/
    ln -fs /usr/include/x86_64-linux-gnu/asm /usr/include/x86_64-linux-musl/

    # linking sys/queue not shipped by musl
    ln -fs /usr/include/x86_64-linux-gnu/sys/queue.h /usr/include/x86_64-linux-musl/sys/

    # linking lib64 to lib
    pushd ${MUSLROOTDIR}
    mkdir -p lib
    ln -fs lib lib64
    popd
}


#
# Download a file and check the hash
# First argument needs to be the url, second is the md5 hash
#
download_file() {
    # set extra filename output or default output
    if [ ! -z $3 ]; then
        output=$3
    else
        output=$(basename "$1")
    fi

    # set default url
    fileurl=$1

    # if we use a mirror we rewrite the url
    if [ $USE_MIRROR == 1 ]; then
        # if we use a custom filename, that
        # filename will be used on the mirror site
        if [ ! -z $3 ]; then
            fileurl=$3
        fi

        fileurl="$MIRRORSRC/$(basename $fileurl)"
    fi

    event "downloading" "${output}"

    if [ -f "${output}" ]; then
        # Check for md5 before downloading the file
        checksum ${output} $2 && return
    fi

    # Download the file
    if [ "${INTERACTIVE}" == "false" ]; then
        curl -L -k -o "${output}" $fileurl
    else
        curl -L -k --progress-bar -C - -o "${output}" $fileurl
    fi

    # Checksum the downloaded file
    checksum ${output} $2 || false
}

download_git() {
    repository="$1"
    branch="$2"
    tag="$3"

    target=$(basename "${repository}")
    logfile="${target}-git.log"

    echo "Loading ${repository}" > "${logfile}"

    if [ -d "${target}" ]; then
        event "updating" "${repository}" "[${branch}]"

        # Ensure branch is up-to-date
        pushd "${target}"

        git fetch

        git checkout "${branch}" >> "${logfile}" 2>&1
        git pull origin "${branch}" >> "${logfile}" 2>&1

        [[ ! -z "$tag" ]] && git reset --hard "$tag" >> "${logfile}"

        popd
        return
    fi

    event "cloning" "${repository}" "[${branch}]"
    git clone -b "${branch}" "${repository}"
}

#
# Downloads all the archives, if the archive is already present
# a retry will be done (if the previous file was not downloaded correctly)
#
download_all() {
    pushd $DISTFILES

    for downloader in ${DOWNLOADERS[@]}; do
        $downloader
    done

    popd
}

#
# Extract all archives
#
extract_all() {
    for extractor in ${EXTRACTORS[@]}; do
        if [[ "$extractor" == *_musl ]]; then
            pushd "${MUSLWORKDIR}"
        else
            pushd "${WORKDIR}"
        fi

        $extractor
        popd
    done
}


#
# Dynamic libraries management
#
resolv_libs() {
    paths=$(grep -hr ^/ /etc/ld.so.conf*)
    for path in $paths; do
        if [ ! -e "$path/libresolv.so.2" ]; then
            continue
        fi

        cp -aL $path/libresolv* "${ROOTDIR}/usr/lib/"
        cp -a $path/libnss_{compat,dns,files}* "${ROOTDIR}/usr/lib/"
        cp -a $path/libnsl* "${ROOTDIR}/usr/lib/"
        return
    done

    echo "[-] warning: no libs found for resolving names"
    echo "[-] you will probably not be able to do dns request"
}

ensure_libs() {
    echo "[+] verifing libraries dependancies"
    pushd "${ROOTDIR}"

    if [ ! -e lib64 ]; then ln -s usr/lib lib64; fi
    if [ ! -e lib ]; then ln -s lib64 lib; fi

    export LD_LIBRARY_PATH=${ROOTDIR}/lib:${ROOTDIR}/usr/lib

    # Copiyng ld-dependancy
    ld=$(ldd /bin/bash | grep ld-linux | awk '{ print $1 }')
    cp -aL $ld lib/

    # Copying resolv libraries
    resolv_libs

    for file in $(find -type f -executable); do
        # Looking for dynamic libraries shared
        libs=$(ldd $file 2>&1 | grep '=>' | grep -v '=>  (' | awk '{ print $3 }' || true)

        # Checking each libraries
        for lib in $libs; do
            libname=$(basename $lib)

            # Library found and not the already installed one
            if [ -e lib/$libname ] || [ "$lib" == "${PWD}/usr/lib/$libname" ]; then
                continue
            fi

            # Grabbing library from host
            cp -avL $lib lib/
        done
    done

    popd
}

#
# Cleaner and optimizer
#
mknod_die() {
    warning "[-] mknod need root access, please run this command as root:"
    warning "[-]   mknod -m 622 "${ROOTDIR}"/dev/console c 5 1"
    warning "[-] and try again."

    exit 1
}

clean_root() {
    echo "[+] cleaning initramfs"

    pushd "${ROOTDIR}"
    mkdir -p dev mnt proc root sys tmp
    rm -rf lib/*.a
    rm -rf lib/*.la
    rm -rf etc/init.d
    rm -rf usr/lib/*.a
    rm -rf usr/lib/*.la
    rm -rf usr/share/doc
    rm -rf usr/share/gtk-doc
    rm -rf usr/share/man
    rm -rf usr/share/locale
    rm -rf usr/share/info
    rm -rf usr/share/bash-completion
    rm -rf usr/lib/pkgconfig
    rm -rf usr/include
    popd
}

clean_staging() {
    echo "[+] cleaning staging files"

    # removing archives
    rm -rf "${DISTFILES}"/*

    # saving kernel
    rm -rf "${TMPDIR}"/*
    mv -f "${WORKDIR}"/linux-* "${TMPDIR}"/
    mv -f "${WORKDIR}"/vmlinuz* "${TMPDIR}"/
    mv -f "${WORKDIR}"/wireguard-* "${TMPDIR}"/
    mv -f "${WORKDIR}"/zinit* "${TMPDIR}"/

    # cleaning staging files
    rm -rf "${WORKDIR}"/*

    # restoring kernel
    mv "${TMPDIR}"/* "${WORKDIR}"/
}

optimize_size() {
    pushd "${ROOTDIR}"

    echo "[+] preparing optimize environment"
    rm -rf "${TMPDIR}"/optimize
    mkdir -p  "${TMPDIR}"/optimize/usr/bin

    echo "[+] saving binaries to keep intact"
    cp -rv usr/bin/corex "${TMPDIR}"/optimize/usr/bin/

    echo "[+] optimizing binaries size"

    for file in $(find ./bin ./sbin ./libexec ./usr/bin ./usr/sbin ./usr/libexec ./usr/lib -type f); do
        # dumping 4 first bytes
        header=$(dd if=$file bs=1 count=4 2> /dev/null | hexdump -e '/1 "%02X"')

        # checking if it's a ELF file
        if [ "$header" == "7F454C46" ]; then
            strip --strip-debug $file || true
        fi
    done

    echo "[+] restoring saved binaries"
    cp -rv "${TMPDIR}"/optimize/* "${ROOTDIR}"/

    echo "[+] cleaning optimized environment"
    rm -rf "${TMPDIR}"/optimize

    popd
}

clean_busybox_outdated() {
    echo "[+] removing busybox symlinks not needed anymore"

    pushd "${ROOTDIR}"/usr
    for file in sbin/*; do
        # our script installs mostly everything under /usr
        # /sbin/ contains mainly busybox symlinks
        # we can safely remove /sbin stuff if we already have it on /usr/sbin
        # this improves the system stability by providing more advanced features
        # (eg: util-linux blkid and not busybox one)
        if [ -e ../$file ]; then
            rm -f ../$file
        fi
    done
    popd
}

#
# Configuration
#
zero_os_root() {
    # Copy init
    echo "[+] installing init script"
    cp "${CONFDIR}/init/init" "${ROOTDIR}/init"
    chmod +x "${ROOTDIR}/init"

    if [ "${BUILDMODE}" = "debug" ]; then
        echo "[+] installing debug init script"
        cp "${CONFDIR}/init/init-debug" "${ROOTDIR}/init-debug"
        chmod +x "${ROOTDIR}/init-debug"
    fi

    # Ensure minimal system directories and symlinks
    echo "[+] creating default directories and files"
    mkdir -p "${ROOTDIR}"/mnt/root
    mkdir -p "${ROOTDIR}"/var/run
    mkdir -p "${ROOTDIR}"/var/log
    mkdir -p "${ROOTDIR}"/var/lock
    mkdir -p "${ROOTDIR}"/var/cache/containers

    # Ensure minimal login logs
    touch "${ROOTDIR}"/var/log/lastlog
    touch "${ROOTDIR}"/var/log/wtmp

    # Legacy mtab symlink
    pushd "${ROOTDIR}/etc"
    ln -sf /proc/mounts mtab
    popd

    # Ensure /run -> /var/run
    pushd "${ROOTDIR}"
    rm -f run
    ln -sf var/run run
    popd

    if [ ! -e "${ROOTDIR}"/dev/console ]; then
        # mknod need to be run as root
        mknod -m 622 "${ROOTDIR}"/dev/console c 5 1 || mknod_die
    fi

    # System configuration
    cp -a "${CONFDIR}"/etc/* "${ROOTDIR}"/etc/

    # System scripts
    cp -a "${CONFDIR}"/usr/udhcp "${ROOTDIR}"/usr/share/

    # Debugfs tool
    cp -a "${CONFDIR}"/debugfs/debugfs "${ROOTDIR}"/usr/sbin/
    cp -a "${CONFDIR}"/debugfs/ssh-add-github-key "${ROOTDIR}"/usr/sbin/
}

#
# Extensions support
#
build_extensions() {
    pushd "${EXTENDIR}"
    echo "[+] entering extensions system"

    for extension in *; do
        # skip if no extensions found
        [[ $extension == '*' ]] && break

        if [ ! -d "${extension}" ]; then
            echo "[-] ${extension}: not a directory"
            continue
        fi

        pushd "${extension}"

        if [ ! -f "${extension}.sh" ]; then
            echo "[-] ${extension}: no callable script found"
            continue
        fi

        echo "[+] building extension: ${extension}"

        # call extension
        . ./"${extension}.sh"

        popd
    done

    echo "[+] extensions executed"

    popd
}

#
# Helpers
#
get_size() {
    du -shc --apparent-size $1 | tail -1 | awk '{ print $1 }'
}

end_summary() {
    root_size=$(get_size "${ROOTDIR}")
    kernel_size=$(get_size "${WORKDIR}"/vmlinuz.efi)

    success "[+] --- initramfs ready ---"
    echo "[+] initramfs root size: $root_size"
    echo "[+] kernel size: $kernel_size"
}

#
# Files cleaner
#
remove_staging() {
    echo "[+] cleaning ${WORKDIR}"
    rm -rf "${WORKDIR}"/*

    echo "[+] source cleared"
}

remove_root() {
    echo "[+] cleaning ${ROOTDIR}"
    rm -rf "${ROOTDIR}"/*

    echo "[+] root cleared"
}

#
# Main stuff
#
main() {
    #
    # Display some informations
    #
    info "==============================="
    info "=  Zero-OS Initramfs Builder  ="
    info "==============================="
    echo ""

    #
    # Let's do the job
    #
    prepare

    if [[ $DO_CLEAN == 1 ]]; then
        remove_staging
        exit 0
    fi

    if [[ $DO_MRPROPER == 1 ]]; then
        remove_staging
        remove_root
        exit 0
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_DOWNLOAD == 1 ]]; then
        download_all
        extract_all
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_BUSYBOX == 1 ]]; then
        build_busybox
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_TOOLS == 1 ]]; then
        # active build
        build_zlib
        build_fuse
        build_openssl
        build_certs
        build_linuxutil
        build_parted
        build_e2fsprogs
        build_btrfs
        build_dnsmasq
        build_nftables
        build_iproute2
        build_dmidecode
        build_unionfs
        build_eudev
        build_kmod
        build_openssh
        build_smartmon
        build_netcat
        build_redis
        build_ethtool
        build_rtinfo
        build_seektime
        build_curl
        build_zflist
        build_haveged
        build_wireguard
        build_dhcpcd
        build_bcache
        build_runc
        build_tcpdump
        build_rscoreutils
        build_firmware
        build_xfsprogs

        # active musl packages
        build_zlib_musl
        build_libcap_musl
        build_jsonc_musl
        build_openssl_musl
        build_libwebsockets_musl
        build_corex_musl

        ## disabled build
        # build_qemu
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_ORK == 1 ]]; then
        # build_ork
        build_restic
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_CORES == 1 ]]; then
        build_zinit
        build_zfs

        # force re-download if we specify --cores
        if [[ $DO_CORES == 1 ]]; then
            download_modules
            prepare_modules
        fi

        build_modules
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_EXTENSIONS == 1 ]]; then
        build_extensions
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_KERNEL == 1 ]] || [[ $DO_KMODULES == 1 ]]; then
        ensure_libs
        clean_root
        optimize_size
        clean_busybox_outdated
        zero_os_root
        build_kernel
        end_summary
    fi

    if [[ $DO_COMPACT == 1 ]]; then
        clean_staging
    fi
}

main
