#!/bin/sh

ntp_flags=$(cat /proc/cmdline | grep -o 'ntp=.*')

if [ -n "$ntp_flags" ]; then
  ntp_flags=${ntp_flags#*=}

  temp_file=$(mktemp)

  for server in $(echo "$ntp_flags" | tr ',' ' '); do
    echo "server $server" >> $temp_file
  done

  if [ -s "$temp_file" ]; then
    mv $temp_file /etc/ntp.conf
  fi
fi

exec ntpd -n