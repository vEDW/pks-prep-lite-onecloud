#!/bin/bash

source env_epmc

# USER : director
# PASSWD : https://OPS-MANAGER-FQDN/api/v0/deployed/director/credentials/director_credentials

PASSWD=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/director_credentials -s | jq '.[] | .value.password' | sed -e "s/\"//g" )

echo -e "director\n${PASSWD}" | bosh -e pks log-in
