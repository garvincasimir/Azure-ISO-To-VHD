#!/bin/bash

#Bake image
echo "Building image with packer"
cd /root/config
packer fix template.json > template-fixed.json
PACKER_LOG=1 packer build template-fixed.json

echo "Packer image build complete. Converting to VHD format."

#MB=$((1024*1024))
#size=$(qemu-img info -f raw --output json disk/baked | \
#gawk 'match($0, /"virtual-size": ([0-9]+),/, val) {print val[1]}')

#rounded_size=$((($size/$MB + 1)*$MB))

#qemu-img resize -f raw disk/baked $rounded_size

qemu-img convert -f raw -o subformat=fixed,force_size -O vpc disk/baked baked.vhd
