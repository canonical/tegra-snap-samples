#! /usr/bin/bash

set -e

echo -n "/var/snap/nvidia-tegra-drivers-36/current/firmware" > /sys/module/firmware_class/parameters/path
$SNAP/usr/bin/deviceQuery
