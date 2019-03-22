#!/bin/bash

wget https://releases.hashicorp.com/packer/1.3.5/packer_1.3.5_linux_amd64.zip
unzip packer_1.3.5_linux_amd64.zip
chmod +x packer
mv packer /usr/local/bin