#! /usr/bin/bash

set -e

CMD=$SNAP/usr/bin/$1
TARGET=$(readlink -f $CMD)
TARGET_DIR=$(dirname $TARGET)

shift 1

EXEC=$(basename $CMD)

if [ -n "$1" ]; then
        EXTRA_ARGS=$@
elif [ $EXEC == "ptxgen" ]; then
        EXTRA_ARGS="test.ll"
fi

cd $TARGET_DIR
$EXEC $EXTRA_ARGS
