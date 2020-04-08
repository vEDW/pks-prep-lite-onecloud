# source define_download_version_env
source define_download_version_env

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

sudo apt-get update -y
sudo apt-get upgrade -y

# bosh
curl -LO https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSHRELEASE}-linux-amd64
sudo cp bosh-cli-${BOSHRELEASE}-linux-amd64 ${BINDIR}/bosh
sudo chmod ugo+x ${BINDIR}/bosh 
rm bosh-cli-${BOSHRELEASE}-linux-amd64
