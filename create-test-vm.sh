#!/bin/bash

RESOURCE_GROUP=$1
VM_NAME="$2-test"
STORAGE_ACCOUNT=$3
CONTAINER=$4
BASE_IMAGE_NAME=$5
REGION=$6
BUILD_ID=$7
VM_PASSWORD=$8
IMAGE_NAME="$BASE_IMAGE_NAME-$BUILD_ID.vhd"
MANAGED_IMAGE_NAME="$BASE_IMAGE_NAME-$BUILD_ID"

IMAGE_URL=$(az storage blob url \
                    --container-name $CONTAINER \
                    --name $IMAGE_NAME \
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
    --admin-username azureuser \
    --admin-password $VM_PASSWORD \
    --boot-diagnostics-storage $STORAGE_ACCOUNT \
    --size Standard_D2s_v3
