#!/bin/bash

echo "start ash terminal"
while true; do
    getty -l /bin/ash -n 19200 tty2
done
