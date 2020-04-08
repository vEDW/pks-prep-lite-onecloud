#!/bin/bash

# Created and maintained by Eric De Witte - https://github.com/vEDW/pks-prep-lite-onecloud.git
# This script is for identifying latest version of cli tools to populate define_download_version_env
#
# inspired by Luke Childs : https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c

source define_download_version_env

if [ $APIREFRESHTOKEN = "<insert-refresh-token-here>" ]
then
    echo "Update APIREFRESHTOKEN value in set_env before running it"
    exit 1
fi


#Login
pivnet login --api-token=$APIREFRESHTOKEN

# Pivnet Releases

# OPS manager
OPSMANRELEASE=`pivnet rs -p ops-manager --format=json | jq -r '.[0].version'`
echo "OPSMANRELEASE=$OPSMANRELEASE"
