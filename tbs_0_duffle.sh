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
DuffleFileID=`pivnet pfs -p build-service -r $BUILDSERVICERELEASE | grep 'duffle-cli-linux' | awk '{ print $2}'`
pivnet download-product-files -p build-service -r $BUILDSERVICERELEASE -i $DuffleFileID

mv duffle-* duffle 
sudo chown root:root duffle
sudo chmod +x duffle
sudo cp duffle ${BINDIR}/duffle
rm duffle

duffle --version


