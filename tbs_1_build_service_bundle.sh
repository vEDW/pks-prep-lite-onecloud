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

# TBS bundle file
pivnet login --api-token=$APIREFRESHTOKEN
BundleFileID=`pivnet pfs -p build-service -r $BUILDSERVICERELEASE | grep 'build-service-bundle.tgz' | awk '{ print $2}'`
pivnet download-product-files -p build-service -r $BUILDSERVICERELEASE -i $BundleFileID -d $BITSDIR


curl https://10.40.14.38/api/systeminfo/getcert -k > harbor.crt
sudo cp harbor.crt /etc/docker/certs.d/harbor.corp.local/ca.crt
sudo service docker restart

sudo cp harbor.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

docker login harbor.corp.local

duffle relocate -f $BITSDIR/build-service-0.1.0.tgz -m $BITSDIR/relocated.json -p harbor.corp.local/tbs/build-service

create credntials.yml
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


duffle install BUILD-SERVICE-INSTALLATION-NAME -c /tmp/credentials.yml  \
    --set kubernetes_env=CLUSTER-NAME \
    --set docker_registry=DOCKER-REGISTRY \
    --set docker_repository=DOCKER-REPOSITORY \
    --set registry_username=REGISTRY-USERNAME \
    --set registry_password=REGISTRY-PASSWORD \
    --set custom_builder_image=BUILDER-IMAGE-TAG \
    -f /tmp/build-service-${version}.tgz \
    -m /tmp/relocated.json

duffle install skippy -c /tmp/credentials.yml  \
    --set kubernetes_env=cicd \
    --set docker_registry=harbor.corp.local \
    --set docker_repository=tbs/build-service \
    --set registry_username=tbs-user \
    --set registry_password=VMware1! \
    --set custom_builder_image=harbor.corp.local/tbs/build-service/default-builder \
    -f /tmp/build-service-0.1.0.tgz \
    -m /tmp/relocated.json