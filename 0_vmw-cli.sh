# source define_download_version_env
source define_download_version_env

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt1-dev libxml2-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 sshpass jq dnsmasq iperf3 sshpass npm

# vwm-cli - requires nodejs >=8
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install vmw-cli --global