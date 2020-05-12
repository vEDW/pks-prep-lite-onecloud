#!/bin/bash

# get download env
source define_download_version_env

if [ $APIREFRESHTOKEN = "<insert-refresh-token-here>" ]
then
    echo "Update APIREFRESHTOKEN value in set_env before running it"
    exit 1
fi

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

# TBS bundle file
pivnet login --api-token=$APIREFRESHTOKEN
BundleFileID=`pivnet pfs -p build-service -r $BUILDSERVICERELEASE | grep 'build-service-bundle.tgz' | awk '{ print $2}'`
pivnet download-product-files -p build-service -r $BUILDSERVICERELEASE -i $BundleFileID -d $BITSDIR

docker login harbor.corp.local

duffle relocate -f $BITSDIR/build-service-0.1.0.tgz -m $BITSDIR/relocated.json -p harbor.corp.local/tbs/build-service
