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

git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
sudo ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
sudo ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
cat << FOE >> ~/.bashrc


#kubectx and kubens
export PATH=~/.kubectx:\$PATH
FOE
