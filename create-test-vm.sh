#!/bin/bash

RESOURCE_GROUP=$1
VM_NAME=$2
STORAGE_ACCOUNT=$3
CONTAINER=$4
BASE_IMAGE_NAME=$5
REGION=$6
BUILD_ID=$7
VM_USERNAME=$8
VM_PASSWORD=$9
VM_SIZE=${10}
IMAGE_NAME="$BASE_IMAGE_NAME-$BUILD_ID.vhd"
MANAGED_IMAGE_NAME="$BASE_IMAGE_NAME-$BUILD_ID"

#https://docs.microsoft.com/en-us/azure/storage/common/authorize-data-operations-cli
KEY=$(az storage account keys list \
    -n $STORAGE_ACCOUNT \
    --query [0].value \
    -o tsv)

IMAGE_URL=$(az storage blob url \
                    --container-name $CONTAINER \
                    --name $IMAGE_NAME \
                    --auth-mode key \
                    --account-key $KEY \
                    --account-name $STORAGE_ACCOUNT -o tsv)    

az image create \
    -g $RESOURCE_GROUP\
	--name $MANAGED_IMAGE_NAME \
    --os-type Linux \
    --source $IMAGE_URL

az vm create \
    -g $RESOURCE_GROUP \
    --name $VM_NAME \
    --image $MANAGED_IMAGE_NAME \
    --admin-username $VM_USERNAME \
    --admin-password $VM_PASSWORD \
    --boot-diagnostics-storage $STORAGE_ACCOUNT \
    --size $VM_SIZE
