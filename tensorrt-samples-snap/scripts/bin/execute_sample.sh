#! /usr/bin/bash

set -e

# tensorrt-samples need to be executed from a place with r/w
# permissions, so use this wrapper to take the name of a sample
# as an argument and execute it from $SNAP_DATA where it was
# copied using an install hook
cd $SNAP_DATA/tensorrt/bin
./$1
