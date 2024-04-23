#!/bin/sh

ntp_flags=$(grep -o 'ntp=.*' /proc/cmdline | sed 's/^ntp=//')

params=""
if [ -n "$ntp_flags" ]; then
  params=$(echo "-p $ntp_flags" | sed s/,/' -p '/g)
fi

exec ntpd -n $params