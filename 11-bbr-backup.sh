#!/bin/bash

source env_epmc


# Verify your BBR Version : done with script 9_bbr_cli.sh

echo "getting bosh credentials"

BoshPASSWD=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/director_credentials -s | jq '.[] | .value.password' | sed -e "s/\"//g" )
echo -e "director\n${BoshPASSWD}" | bosh -e pks log-in

BOSH_CLIENT_CREDENTIAL=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/bosh_commandline_credentials -s | jq -r '.credential' )
export $BOSH_CLIENT_CREDENTIAL

# Perform bbr pre-check
echo
echo "Performing director backup"

bbr director  --host $DIRECTOR  --username bbr --private-key-path bbr_key.pem  backup

echo
echo "Performing TKGI control plane backup"

bbr deployment --target $DIRECTOR  --username $BOSH_CLIENT --deployment $PKSDeployGuid --ca-cert ca.crt backup

#Retrieve Your Cluster Deployment Names

echo
echo "Performing k8s clusters backup"

k8sClusters=$(bosh -e pks deployments --json | jq -r '.Tables[].Rows[] | select(.name | contains("service-instance_")) | .name')
for CLUSTERUUID in ${k8sClusters[@]}
do
    bbr deployment --target $DIRECTOR  --username $BOSH_CLIENT --deployment $CLUSTERUUID --ca-cert ca.crt backup
done

