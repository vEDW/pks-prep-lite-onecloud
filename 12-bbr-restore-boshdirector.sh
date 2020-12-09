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

# Perform bbr pre-check
echo
echo "Performing director backup"

nohup bbr director --host $DIRECTOR  --username bbr --private-key-path bbr_key.pem  restore --artifact-path $1

echo "Done."
