#!/bin/bash

RESOURCE_GROUP=$1
REGION=$2
VM_NAME=$3
VM_USERNAME=$4
VM_PASSWORD=$5
VM_SIZE=$6

#Create resource group if not exists
VM_EXISTS=$(az group exists -g $RESOURCE_GROUP)
if [ $VM_EXISTS = 'true' ]
then
    echo "Resource group $RESOURCE_GROUP already exists. Deleting..."
    az group delete --name $RESOURCE_GROUP --yes
fi
az group create --name $RESOURCE_GROUP --location $REGION

echo "Generating cloud init config for vm $VM_NAME"
#Regenrate cloud init
./gen-init.sh

echo "Does cloud init file look ok?"
cat cloud-init-gen.yaml

echo "Building inception vm $VM_NAME in Resource Group $RESOURCE_GROUP in $REGION"
#Create Azure Builder VM
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image UbuntuLTS \
    --admin-username $VM_USERNAME \
    --admin-password $VM_PASSWORD \
    --size $VM_SIZE \
    --custom-data cloud-init-gen.yaml

echo "Inception vm $VM_NAME created. Waiting for cloud init."
#Wait for cloud init to complete on Builder VM
az vm run-command invoke \
-g $RESOURCE_GROUP \
-n $VM_NAME \
--command-id RunShellScript \
--scripts "while [ ! -f '/var/lib/cloud/instance/boot-finished' ]; do sleep 2; done"


az vm open-port -g $RESOURCE_GROUP  -n $VM_NAME --port 3389