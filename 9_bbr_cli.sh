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
BBRFileID=`pivnet pfs -p p-bosh-backup-and-restore -r $BBRRELEASE | grep 'BOSH Backup and Restore Linux' | awk '{ print $2}'`
pivnet download-product-files -p p-bosh-backup-and-restore -r $BBRRELEASE -i $BBRFileID

mv bbr-* bbr 
sudo chown root:root bbr
sudo chmod +x bbr
sudo cp bbr ${BINDIR}/bbr
rm bbr

bbr --version


