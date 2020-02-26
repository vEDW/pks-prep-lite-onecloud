#!/bin/bash

# get download env
source define_download_version_env

# test env variables
if [ $VMWUSER = '<username>' ]
then
    echo "Update VMWUSER value in set_env before running it"
    exit 1
fi

if [ $VMWPASS = '<password>' ]
then
    echo "Update VMWPASS value in set_env before running it"
    exit 1
fi

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

# OVFTOOL
sudo vmw-cli index $OVFTOOLPG
ovfFileName=`sudo vmw-cli json productGroup:$OVFTOOLPG,fileName:lin.X86 | jq -r '.fileName'`
sudo vmw-cli get $ovfFileName
mv $ovfFileName $BITSDIR
echo "export ovfFileName="$BITSDIR"/"$ovfFileName >> software_filenames.env

# NSX-T
sudo vmw-cli index $NSXTPG
# get manager
nsxMgrFileName=`sudo vmw-cli json productGroup:$NSXTPG,fileType:ova,fileName:unified | jq -r '.fileName'`
sudo vmw-cli get $nsxMgrFileName
mv $nsxMgrFileName $BITSDIR
echo "export nsxMgrFileName="$BITSDIR"/"$nsxMgrFileName >> software_filenames.env
