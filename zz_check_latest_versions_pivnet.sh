#!/bin/bash

# Created and maintained by Eric De Witte - https://github.com/vEDW/pks-prep-lite-onecloud.git
# This script is for identifying latest version of cli tools to populate define_download_version_env

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
echo "export OPSMANRELEASE=$OPSMANRELEASE"

# PKS
PKSRELEASE=`pivnet rs -p pivotal-container-service --format=json | jq -r '.[0].version'`
echo "export PKSRELEASE=$PKSRELEASE"

# Harbor
HARBORRELEASE=`pivnet rs -p harbor-container-registry --format=json | jq -r '.[0].version'`
echo "export HARBORRELEASE=$HARBORRELEASE"

#Xenial Stemcell
STEMCELLXENIALRELEASE=`pivnet rs -p stemcells-ubuntu-xenial --format=json | jq -r '.[0].version'`
echo "export STEMCELLXENIALRELEASE=$STEMCELLXENIALRELEASE"

# Build-service 
BUILDSERVICERELEASE=`pivnet rs -p build-service --format=json | jq -r '.[0].version'`
echo "export BUILDSERVICERELEASE=$BUILDSERVICERELEASE"

# BBR
BBRRELEASE=`pivnet rs -p p-bosh-backup-and-restore --format=json | jq -r '.[0].version'`
echo "export BBRRELEASE=$BBRRELEASE"
