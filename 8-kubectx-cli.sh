# source define_download_version_env
source define_download_version_env


#kubectl krew install ctx
#kubectl krew install ns

curl -L0 https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx > kubectx
chmod +x kubectx
sudo mv kubectx ${BINDIR}/kubectx


curl -L0 https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens > kubens
chmod +x kubens
sudo mv kubens ${BINDIR}/kubens
