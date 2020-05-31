#!/bin/bash

IMAGE_URL=$1
SAS_TOKEN=$2

cd /root/config

#--overwrite on by default: overwrite existing files
azcopy cp \
    baked.vhd \
    "$IMAGE_URL?$SAS_TOKEN" \
    --blob-type PageBlob 