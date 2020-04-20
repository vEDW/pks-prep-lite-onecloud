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

# pks cli
pivnet login --api-token=$APIREFRESHTOKEN
PKSFileID=`pivnet pfs -p pivotal-container-service -r $PKSRELEASE | grep 'PKS CLI - Linux' | awk '{ print $2}'`
pivnet download-product-files -p pivotal-container-service -r $PKSRELEASE -i $PKSFileID

mv pks-linux-amd64* pks 
sudo chown root:root pks
sudo chmod +x pks
sudo cp pks ${BINDIR}/pks
rm pks

pks --version


