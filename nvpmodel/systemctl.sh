#!/bin/bash

if [ $# -eq 0 ] ; then
    logger -t nvpmodel "No arguments supplied"
elif [ "$1" = "is-active" ] ; then
    if [ "$2" = "nvfancontrol" ] ; then
        nvfancontrol_status=$(snapctl services | grep nvpmodel.nvfancontrol | tr -s " " | cut -d " " -f3)
        logger -t nvpmodel "nvfancontrol status: $nvfancontrol_status"
        echo "$nvfancontrol_status"
    else
        logger -t nvpmodel "Unrecognized option: $2"
    fi
else
    logger -t nvpmodel "Unrecognized options: $@"
fi
