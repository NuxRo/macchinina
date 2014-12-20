#!/bin/sh

# start a getty on hvc0, but only if we asked for it - ie this is called by /boot/grub/grub.conf when booted by pvgrub

grep -q hvc0 /proc/cmdline && /sbin/getty -L  hvc0 115200 vt100 || sleep 86400
