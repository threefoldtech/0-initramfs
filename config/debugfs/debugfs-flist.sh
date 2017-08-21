#!/bin/bash

ROOTBUNTU="/tmp/ubuntu-xenial"
TARGET="/tmp/ubuntu-debugfs.tar.gz"

# preparing target
mkdir -p ${ROOTBUNTU}
rm -rf ${ROOTBUNTU}/*
rm -rf ${TARGET}

echo "Installing image into: ${ROOTBUNTU}"
echo "Exporting flist to: ${TARGET}"
echo ""
echo "Bootstrapping the base image..."

# installing system
debootstrap \
  --arch=amd64 \
  --components=main,restricted,universe,multiverse \
  --include curl,ca-certificates,tcpdump,ethtool,pciutils,strace,lsof,htop,binutils \
  xenial ${ROOTBUNTU} \
  http://archive.ubuntu.com/ubuntu/

echo "Debugfs base system installed"

files=$(find ${ROOTBUNTU} | wc -l)
rootsize=$(du -sh ${ROOTBUNTU})
echo "${rootsize}, ${files} files installed"

echo "Customizing settings..."

touch ${ROOTBUNTU}/root/.sudo_as_admin_successful
echo 'export PS1="(debugfs) $PS1"' >> ${ROOTBUNTU}/root/.bashrc
echo 'cat /root/.debugfs' >> ${ROOTBUNTU}/root/.bashrc

echo "You are now on debugfs environment" > ${ROOTBUNTU}/root/.debugfs
echo "Don't forget to 'apt-get update' before installing new packages" >> ${ROOTBUNTU}/root/.debugfs
echo "" >> ${ROOTBUNTU}/root/.debugfs

echo "Cleaning installation..."

# cleaning documentation and not needed files
find ${ROOTBUNTU}/usr/share/doc -type f ! -name 'copyright' | xargs rm -f
find ${ROOTBUNTU}/usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en' | xargs rm -rf
rm -rf ${ROOTBUNTU}/usr/share/info
rm -rf ${ROOTBUNTU}/usr/share/man
rm -rf ${ROOTBUNTU}/usr/share/lintian
rm -rf ${ROOTBUNTU}/var/cache/apt/archives/*deb
rm -rf ${ROOTBUNTU}/var/lib/apt/lists/*_Packages

files=$(find ${ROOTBUNTU} | wc -l)
rootsize=$(du -sh ${ROOTBUNTU})
echo "${rootsize}, ${files} files installed"

echo "Archiving..."
pushd ${ROOTBUNTU}
tar -czf ${TARGET} *
popd

ls -alh ${TARGET}
echo "Debugfs flist is ready."
