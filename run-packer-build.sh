#!/bin/bash

RESOURCE_GROUP=$1
VM_NAME=$2

az vm run-command invoke \
-g $RESOURCE_GROUP \
-n $VM_NAME \
--command-id RunShellScript \
--scripts "/root/packer-build.sh"