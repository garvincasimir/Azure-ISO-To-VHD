#!/bin/bash

#Old Version
wget -O azcopy.tar.gz https://aka.ms/downloadazcopylinux64
tar -xf azcopy.tar.gz
sudo ./install.sh

#Version 10 - 
#wget -O azcopy.tar https://aka.ms/downloadazcopy-v10-linux
#tar --strip-components=1 -xf azcopy.tar
#chmod +x azcopy
#mv azcopy /usr/local/bin


