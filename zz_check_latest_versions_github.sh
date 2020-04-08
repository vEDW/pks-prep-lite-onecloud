#!/bin/bash

# Created and maintained by Eric De Witte - https://github.com/vEDW/pks-prep-lite-onecloud.git
# This script is for identifying latest version of cli tools to populate define_download_version_env
#
# inspired by Luke Childs : https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c


get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' |                                    # Pluck JSON value
    cut -d "v" -f 2
}

# Github Releases

# pivnet 
PIVNETRELEASE=`get_latest_release "pivotal-cf/pivnet-cli"`
echo "export PIVNETRELEASE=$PIVNETRELEASE"

# om cli
OMRELEASE=`get_latest_release "pivotal-cf/om"`
echo "export OMRELEASE=$OMRELEASE"

# bosh cli
BOSHRELEASE=`get_latest_release "pivotal-cf/om"`
echo "export BOSHRELEASE=$BOSHRELEASE"

# helm cli
HELMRELEASE=`get_latest_release "helm/helm"`
echo "export HELMRELEASE=$HELMRELEASE"