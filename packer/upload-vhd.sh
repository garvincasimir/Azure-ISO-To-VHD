#!/bin/bash

IMAGE_URL=$1
SAS_TOKEN=$2

cd /root/config

#--quiet: overwrite existing files
azcopy \
    --source baked.vhd \
    --destination $IMAGE_URL \
    --blob-type page \
    --dest-sas $SAS_TOKEN \
    --quiet 