#!/bin/bash

# script based on procedure : https://docs.pivotal.io/pks/1-7/shutdown-startup.html

# confirm shutdown 

echo "This script is going to shutdown your installation of TKGI."
echo "It will stop your kubernetes clusters, the TKGI control plane, Harbor instance."
echo
echo "please make sure your important applications running on kubernetes have been shut down properly."
echo
echo "Proceed with shutdown ? Confirm by typing the word [shutdown]"

read -p ">" answer
case ${answer} in
    shutdown )
        echo "shutting down TKGI"
    ;;
    * )
        echo action canceled
        exit 1
    ;;
esac

source env_epmc

# USER : director
# PASSWD : https://OPS-MANAGER-FQDN/api/v0/deployed/director/credentials/director_credentials

PASSWD=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/director_credentials -s | jq '.[] | .value.password' | sed -e "s/\"//g" )

echo -e "director\n${PASSWD}" | bosh -e pks log-in

# Step 1: Disable BOSH Resurrection

bosh -e pks update-resurrection off

#Step 2: Shut Down Customer Apps
# This step is skipped and mentioned as prereq in script prompt

# Step 3: Shut Down Kubernetes Clusters

k8sClusters=$(bosh -e pks deployments --json | jq -r '.Tables[].Rows[] | select(.name | contains("service-instance_")) | .name')
for CLUSTERUUID in ${k8sClusters[@]}
do
    echo "Stopping deployment $CLUSTERUUID"
    bosh -e pks vms -d $CLUSTERUUID --json | jq -r '.Tables[].Rows[] | "\(.instance)\t\(.vm_cid)\t\(.ips)\t\(.process_state)"'
    echo "Stopping Worker(s)"
    bosh -e pks -d $CLUSTERUUID stop worker -n
    echo "Stopping Master(s)"
    bosh -e pks -d $CLUSTERUUID stop master -n
done

# shut down Kubernetes cluster VMs


# Step 4: Shut Down the Enterprise PKS API and Database VMs

tkgiUUID=$(bosh -e pks deployments --json | jq -r '.Tables[].Rows[] | select(.name | contains("pivotal-container-service-")) | .name')
bosh -e pks -d $tkgiUUID stop  -n


