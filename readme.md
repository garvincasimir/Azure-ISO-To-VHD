Have you ever had to manually install an operating system from scratch to create base images for use in the cloud? Are you required to periodically rebuild these base images because of patches and updates? Are you working on a packer plugin? This repository introduces an end to end DevOps pipeline for creating base images from OS install disks in ISO format. 

**How will this work?**
This process relies on the [nested virtualization](https://azure.microsoft.com/en-us/blog/nested-virtualization-in-azure/) feature available in Azure. First, A builder VM capable of running nested VMs will be created. Then within the builder VM, packer will be used to create the base images. Once the image creation process is complete, images are copied from the builder VM to Azure storage. From there, these images can be used to create VMs or used as source images in a separate pipeline based on the packer [Azure Builder](https://www.packer.io/docs/builders/azure.html). 

![ISO to VHD in Azure](https://thepracticaldev.s3.amazonaws.com/i/m0n2aipl0oh0n8pa7wms.png)


**Requirements**
There are a few different tools required to fully automate this process. If you are not familiar with any of them it would help to read up on them before proceeding. 

* Create a free [Azure DevOps account](https://azure.microsoft.com/en-us/services/devops/) if you don't already have one. Then follow the documentation to create a [basic pipeline](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started-designer?view=azure-devops&tabs=new-nav). 
* Signup for an [Azure free trial](https://azure.microsoft.com/en-us/offers/ms-azr-0044p/) if you don't already have access to an Azure subscription. 
* This process relies on packer to build images so please visit the [getting started](https://www.packer.io/intro) page to familiarize yourself with the tool. Specifically, the [Qemu](https://www.packer.io/docs/builders/qemu.html) based image builder. 
* The image builder will be an Ubuntu VM configured using [cloud init](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init). If you are not familiar with cloud init, please take some time to [learn](https://cloudinit.readthedocs.io/en/latest/) about it. 
* The packer created nested VMs will use [kickstart](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) files to automatically install the OS. In this case, I have chosen [Centos](https://www.centos.org/download/) as the base OS. 

**The Repository**
The source code repository for this pipeline will contain a set of bash scripts and the config files required for configuring the builder and nested VMs. Please download them from [this repository](https://github.com/garvincasimir/Azure-ISO-To-VHD) and upload to your Azure DevOps repository. You also have the option of using a [Github repository](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops) as the source of a DevOps pipeline.

At this point you should have the following files and directory layout in your repository
![ISO to VHD In Azure](https://thepracticaldev.s3.amazonaws.com/i/1xuywpakul21w3i5swc3.png)

**The Builder VM**
The *cloud-init.yaml* is used to configure the Ubuntu Builder VM. This vm will be created using the latest Ubuntu image in the [Azure Marketplace](https://azuremarketplace.microsoft.com/en-au/marketplace/apps/Canonical.UbuntuServer). The cloud init file will also contain a base64 representation of the bash scripts required to install packer, build dependencies and config files.  Keep in mind that this file is only used as a template. The *gen-init.sh* script replaces all file paths in *cloud-init.yaml* with the base64 representation of the file and saves the result to *cloud-init-gen.yaml*. Please add this file to your *.gitignore* as it should be generated during the build process. 

The *packer-build.sh* script will be used to build the image. It will be run from Azure DevOps using the Azure CLI [run-command](https://docs.microsoft.com/en-us/cli/azure/vm/run-command?view=azure-cli-latest#az-vm-run-command-invoke) feature. This feature allows you to run a command within an Azure vm without an SSH connection. Learn more about run-command [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/run-command). 

**The Pipeline**
The build pipeline consists of 4 agent jobs. 
* The *Setup* job contains tasks responsible for creating the builder vm. 
* The *Build* job contains the tasks responsible for running packer. 
* The *Upload* job uploads the finished VHD to Azure storage. 
* The optional *Test Create VM From VHD* job creates a test vm from from the uploaded VHD. 

It is very important that each job is configured to depend on the preceding job. Otherwise Azure DevOps might run them out of order. Technically, these tasks can all run within a single agent job. However, they are separated to stay within the 30 minute run time allowed on hosted agents in the free tier.

![Pipeline Setup](https://thepracticaldev.s3.amazonaws.com/i/bul6ccsjzjzjs0k4bxuh.png)

Please perform the following actions:
* [create the storage account](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal) that will be used to upload the finished base images. 

* Create the 4 agent jobs mentioned above. Be sure to configure each job to depend on the preceding job.

* Add the following variables to the build pipeline. Please include everything that isn't a system variable. ![pipeline variables](https://thepracticaldev.s3.amazonaws.com/i/6s1ssm9qkpv80z7rkp15.png)

The resource group name you select should not already exist. __**The script will delete the resource group if it exists**__. After the image is uploaded to storage, the resource group and all the resources in it are no longer needed. Deleting the resource group will delete the group and all resources in it. Please do not deploy any other resources to this group. Select a name that can be dedicated to this pipeline. The Azure connection used in the CLI tasks should have permissions to delete/create resource groups, managed images, storage SAS tokens and virtual machines.

***Deploy Builder VM***
* Create a new Azure CLI task in the *Setup* job and name it *Deploy Builder VM to Azure*. 
* Configure the task to run the *create-inception.sh* script and include the previously created variables as parameters. ![deploy builder vm](https://thepracticaldev.s3.amazonaws.com/i/oymy0rjkney2f1316hks.png)

**Run Packer Build**
* Create a new Azure CLI task in the *Build* job and name it *Run Packer Build on Builder VM*. 
* Configure the task to execute the *run-packer-build.sh* script and include the previously created variables as parameters. ![Run packer build](https://thepracticaldev.s3.amazonaws.com/i/lj1uo79py7iayogghgi4.png)

**VHD upload**
* Create a new Azure CLI task in the *Upload* job and name it *Run Upload VHD*.
* Configure the task to execute the *run-upload-vhd.sh* script and include the previously created variables as parameters. ![Upload VHD](https://thepracticaldev.s3.amazonaws.com/i/sb8qrq69ul75nneke9b3.png)

**Create a test VM**
* Create a new Azure CLI task in the *Test Create VM From VHD* job and name it *Create Test VM*.
* Configure the task to execute the *create-test-vm.sh* script and include the previously created variables as parameters. ![Upload VHD](https://thepracticaldev.s3.amazonaws.com/i/1y9948lz1vtwe1g1k1xc.png)

**Troubleshooting**
If your image isn't being built for some reason I recommend using remote desktop to troubleshoot. The script configures the image builder vm to enable RDP access to allow frictionless troubleshooting. 
* The osx based RDP client from Microsoft seems to be the most responsive. 
* From the builder VM desktop start a root based terminal and run the */root/packer-buil.sh* build script. 
* Take note of the vnc connection information in the console output. e.g. vnc://127.0.0.1:5909
* Open the remote viewer and enter the VNC connection information
* You can now see and interact with the VM being built
* You an also run packer with the -debug flag so it will pause at each step while you manually interact with the nested vm
* Install [Real VNC Viewer](https://www.realvnc.com/en/connect/download/viewer/) if the pre-installed viewer does not work correctly.

**Summary**
If everything goes right you should have a virtual machine based on the custom VHD generated in your pipeline. When you are happy with the results, create an Azure CLI task responsible for deleting the resource group. This repository contains an exported *pipeline.yaml* and all the scripts and config files mentioned above. Please add messing variables and change values to match your environment.