set -x

telnetd -l /bin/ash
udhcpc -s /usr/share/udhcp/simple.script -i eth0

mkdir /boot
mount /dev/mmcblk0p1 /boot
