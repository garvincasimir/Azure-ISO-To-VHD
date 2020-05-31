#!/bin/bash

IMAGE_URL=$1
SAS_TOKEN=$2

cd /root/config
ls -lh
#--overwrite on by default: overwrite existing files
azcopy cp \
    baked.vhd \
    "$IMAGE_URL?$SAS_TOKEN" \
    --blob-type PageBlob 

#show azcopy logs for more detail errors. SAS redacted automatically.
#might need to get more advanced and query json output.
#Script should return non zero error code
cat .azcopy/*.log