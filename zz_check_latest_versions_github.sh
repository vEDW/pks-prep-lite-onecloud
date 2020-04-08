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

# Usage
# $ get_latest_release "creationix/nvm"
# v0.31.4

# Github Releases

# pivnet
echo "pivnet cli : " 
get_latest_release "pivotal-cf/pivnet-cli"

# om cli
echo "om cli : "
get_latest_release "pivotal-cf/om"

# bosh cli
echo "bosh cli : "
get_latest_release "cloudfoundry/bosh-cli"

# kubectl cli
#echo "kubectl cli : "
#get_latest_release  "kubernetes/kubectl"

# helm cli
echo "helm cli : "
get_latest_release "helm/helm"

