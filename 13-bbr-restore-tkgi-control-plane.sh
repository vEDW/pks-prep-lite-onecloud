#!/bin/bash

source env_epmc

if [[ ! -e $1 ]]; then
    echo "missing artifact path."
    exit
fi

# Verify your BBR Version : done with script 9_bbr_cli.sh

echo "getting bosh credentials"

BoshPASSWD=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/director_credentials -s | jq '.[] | .value.password' | sed -e "s/\"//g" )
echo -e "director\n${BoshPASSWD}" | bosh -e pks log-in

BOSH_CLIENT_CREDENTIAL=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/bosh_commandline_credentials -s | jq -r '.credential' )
export $BOSH_CLIENT_CREDENTIAL

echo
echo "Performing TKGI control plane backup"

PKSDeployGuid=$(bosh -e pks deployments --json | jq -r '.Tables[].Rows[] | select(.name | contains("pivotal-container-service")) | .name')

if [[ ! -e $PKSDeployGuid ]]; then
    echo "TKGI control plane deployment not found in Bosh director."
    echo "please restore bosh director state and verify deployment"
    exit
fi

nohup bbr deployment --target $DIRECTOR  --username $BOSH_CLIENT --deployment $PKSDeployGuid --ca-cert ca.crt restore --artifact-path $1

echo "restore of TKGI control plane done"
echo
echo "please proceed with cluster recreation as needed using command :"
echo "pks upgrade-cluster CLUSTER-NAME"
echo