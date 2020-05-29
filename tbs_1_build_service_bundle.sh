#!/bin/bash

# get download env
source define_download_version_env
source env_epmc

if [ $APIREFRESHTOKEN = "<insert-refresh-token-here>" ]
then
    echo "Update APIREFRESHTOKEN value in set_env before running it"
    exit 1
fi

#checking and creating BITSDIR if needed
if [[ ! -e $BITSDIR ]]; then
    mkdir $BITSDIR
fi

# TBS bundle file
pivnet login --api-token=$APIREFRESHTOKEN
BundleFileID=`pivnet pfs -p build-service -r $BUILDSERVICERELEASE | grep 'build-service-bundle.tgz' | awk '{ print $2}'`
pivnet download-product-files -p build-service -r $BUILDSERVICERELEASE -i $BundleFileID -d $BITSDIR


curl https://$REG_FQDN/api/systeminfo/getcert -k > $BITSDIR/harbor.crt
mkdir /etc/docker/certs.d/$REG_FQDN
sudo cp $BITSDIR/harbor.crt /etc/docker/certs.d/$REG_FQDN/ca.crt
sudo service docker restart

sudo cp $BITSDIR/harbor.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

docker login $REG_FQDN

duffle relocate -f $BITSDIR/build-service-0.1.0.tgz -m $BITSDIR/relocated.json -p $REG_FQDN/tbs/build-service

cat << EOF >  $BITSDIR/credentials.yml
---
name: build-service-credentials
credentials:
 - name: kube_config
   source:
     path: "/tmp/kubeconfig.cicd"
   destination:
     path: "/root/.kube/config"
 - name: ca_cert
   source:
     path: "/tmp/harbor.crt"
   destination:
     path: "/cnab/app/cert/ca.crt"

----
EOF

#duffle install BUILD-SERVICE-INSTALLATION-NAME -c /tmp/credentials.yml  \
#    --set kubernetes_env=CLUSTER-NAME \
#    --set docker_registry=DOCKER-REGISTRY \
#    --set docker_repository=DOCKER-REPOSITORY \
#    --set registry_username=REGISTRY-USERNAME \
#    --set registry_password=REGISTRY-PASSWORD \
#    --set custom_builder_image=BUILDER-IMAGE-TAG \
#    -f /tmp/build-service-${version}.tgz \
#    -m /tmp/relocated.json

duffle install skippy -c $BITSDIR/credentials.yml  \
    --set kubernetes_env=cicd01 \
    --set docker_registry=harbor.corp.local \
    --set docker_repository=tbs \
    --set registry_username=tbs-user \
    --set registry_password=VMware1! \
    --set custom_builder_image=harbor.corp.local/tbs/default-builder \
    -f $BITSDIR/build-service-0.1.0.tgz \
    -m $BITSDIR/relocated.json