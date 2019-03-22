#!/bin/bash

#find all files recursivley and replace full path token with base64 representation
filestoprocess=$(find . -type f -not -path '*/\.*' | cut -d / -f2-)

#copy template
echo "#cloud-config" > cloud-init-gen.yaml
grep -v "#" cloud-init.yaml >> cloud-init-gen.yaml

#find files to replace
for filename in $filestoprocess; do
    fileinbase64=$(base64 -w 0 $filename 2> /dev/null) || fileinbase64=$(base64 -b 0 $filename) #GNU vs BSD
    config=$(cat cloud-init-gen.yaml)
    echo "${config//_("$filename")/$fileinbase64}" > cloud-init-gen.yaml
done
