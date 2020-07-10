#!/bin/bash

source env_epmc


# Verify your BBR Version : done with script 9_bbr_cli.sh

# Retrieve the BBR SSH Credentials
# (ssh public key)
om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/bbr_ssh_credentials -s | jq -r '.[] | .value.private_key_pem' > bbr_key.pem

# Retrieve the BOSH Director Credentials
DirectorPASSWD=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/director_credentials -s | jq '.[] | .value.password' | sed -e "s/\"//g" )

#Retrieve the UAA Client Credentials
# get PKS deployment name
PKSDeployGuid=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/products -s | jq -r '.[] | select(.guid | contains("pivotal-container-service")) | .guid' )
# get UAA Client Credentials
UAAClientName=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/products/$PKSDeployGuid/uaa_client_credentials -s| jq -r '.uaa_client_name' )
UAAClientSecret=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/products/$PKSDeployGuid/uaa_client_credentials -s| jq -r '.uaa_client_secret' )



#Retrieve the BOSH Director Address
# from env_epmc file


#Download the Root CA Certificate
om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /download_root_ca_cert -s > pks_root_ca.cert 

# Retrieve the BOSH Command Line Credentials
# USER : director
# PASSWD : https://OPS-MANAGER-FQDN/api/v0/deployed/director/credentials/director_credentials
rm -fr ~/.bosh
om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/certificate_authorities -s | jq -r '.certificate_authorities | select(map(.active == true))[0] | .cert_pem' > ca.crt 
bosh alias-env pks -e ${DIRECTOR} --ca-cert ca.crt

BoshPASSWD=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/director_credentials -s | jq '.[] | .value.password' | sed -e "s/\"//g" )
echo -e "director\n${BoshPASSWD}" | bosh -e pks log-in

BOSH_CLIENT_CREDENTIAL=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/director/credentials/bosh_commandline_credentials -s | jq -r '.credential' )
export $BOSH_CLIENT_CREDENTIAL

# Perform bbr pre-check

bbr director  --host $DIRECTOR  --username bbr --private-key-path bbr_key.pem  pre-backup-check

bbr deployment --target $DIRECTOR  --username $BOSH_CLIENT --deployment $PKSDeployGuid --ca-cert ca.crt pre-backup-check


#Retrieve Your Cluster Deployment Names

PKSapiPASSWD=$( om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${OPSMANAGERPWD}" -k curl -p /api/v0/deployed/products/$PKSDeployGuid/credentials/.properties.uaa_admin_password -s | jq -r '.credential.value.secret' )

pks login -a $PKS_FQDN -u admin -p $PKSapiPASSWD -k
pks clusters

k8sClusters=$(bosh -e pks deployments --json | jq -r '.Tables[].Rows[] | select(.name | contains("service-instance_")) | .name')
for CLUSTERUUID in ${k8sClusters[@]}
do
    bbr deployment --target $DIRECTOR  --username $BOSH_CLIENT --deployment $CLUSTERUUID --ca-cert ca.crt pre-backup-check
done

