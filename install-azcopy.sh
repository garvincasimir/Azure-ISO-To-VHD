#!/bin/bash

wget -O azcopy.tar https://aka.ms/downloadazcopy-v10-linux
tar --strip-components=1 -xf azcopy.tar
chmod +x azcopy
mv azcopy /usr/local/bin