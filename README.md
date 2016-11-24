# G8OS Initramfs Builder
This repository contains all needed to build the g8os-kernel and initramfs to start our root filesystem.

# Dependencies
Under Ubuntu 16.04, you will need this in order to compile everything:
 - `golang` (version 1.7.1)
 - `xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev asciidoc`

This dependencies is of course valid for any other system but adapt it yourself to your case.

Under Gentoo, you probably already have all the dependancies.

# What does this script do ?
 - First, downloading and checking checksum of all archives needed
 - Extracting archives
 - Compiling:
    - Busybox
    - Fuse (library and userland tools)
    - SSL Certificates (ca-certificates)
    - util-linux (for `lsblk`, ...)
    - Redis (only the server is used)
    - IPFS
    - BTRFS (btrfs-progs)
 - Cleaning and removing useless files
 - Compiling the kernel (initramfs is bundled)


