# source define_download_version_env
source define_download_version_env

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

sudo apt-get update -y
sudo apt-get upgrade -y

# om
curl -LO https://github.com/pivotal-cf/om/releases/download/${OMRELEASE}/om-linux-${OMRELEASE}
sudo chown root om-linux-${OMRELEASE}
sudo chmod ugo+x om-linux-${OMRELEASE}
sudo mv om-linux-${OMRELEASE} ${BINDIR}/om