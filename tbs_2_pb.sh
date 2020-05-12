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

# duffle cli
pivnet login --api-token=$APIREFRESHTOKEN
PbFileID=`pivnet pfs -p build-service -r $BUILDSERVICERELEASE | grep 'pb-cli-linux' | awk '{ print $2}'`
pivnet download-product-files -p build-service -r $BUILDSERVICERELEASE -i $PbFileID

mv pb-* pb 
sudo chown root:root pb
sudo chmod +x pb
sudo cp pb ${BINDIR}/pb
rm pb -f

pb version


