#!/bin/bash

RESOURCE_GROUP=$1
VM_NAME=$2
STORAGE_ACCOUNT=$3
CONTAINER=$4
BASE_IMAGE_NAME=$5
BUILD_ID=$6
IMAGE_NAME="$BASE_IMAGE_NAME-$BUILD_ID.vhd"

#2 Hours should be more than enough time to upload the vhd
#Maybe stick to one platform instead of swallowing errors
expiration=$(date -ud "2 hours" '+%Y-%m-%dT%TZ' 2> /dev/null) || expiration=$(date -uv +2H '+%Y-%m-%dT%TZ' ) #GNU vs #BSD

#https://docs.microsoft.com/en-us/azure/storage/common/authorize-data-operations-cli
KEY=$(az storage account keys list \
    -n $STORAGE_ACCOUNT \
    --query [0].value \
    -o tsv)

#Get a sas token
SAS_TOKEN=$(az storage blob generate-sas \
    --account-name $STORAGE_ACCOUNT \
    --container-name $CONTAINER \
    --name $IMAGE_NAME \
    --auth-mode key \
    --account-key $KEY \
    --permissions cw \
    --expiry $expiration \
    -o tsv)

IMAGE_URL=$(az storage blob url \
                    --container-name $CONTAINER \
                    --auth-mode key \
                    --account-key $KEY \
                    --name $IMAGE_NAME \
                    --account-name $STORAGE_ACCOUNT )                    


#run upload vhd script on builer vm
az vm run-command invoke \
-g $RESOURCE_GROUP \
-n $VM_NAME \
--command-id RunShellScript \
--scripts "/root/upload-vhd.sh $IMAGE_URL '?$SAS_TOKEN'" 

