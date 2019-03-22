#!/bin/bash

dracut -f -v
sudo waagent -force -deprovision
export HISTSIZE=0
