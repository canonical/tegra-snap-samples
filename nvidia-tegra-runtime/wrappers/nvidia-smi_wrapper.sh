#! /usr/bin/bash

set -e

echo -n "$SNAP/lib/firmware" > /sys/module/firmware_class/parameters/path
$SNAP/usr/sbin/nvidia-smi
