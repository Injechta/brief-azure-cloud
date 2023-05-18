#!/bin/bash

# Variables
resourceGroupName="Gregory_E"
location="westeurope"
vmName="vm-script-azure-files"
vmSize="Standard_DS2_v2"
adminUsername="groot"
adminPassword="grootPassword@1"
storageAccountName="stockage-script"
shareName="azure-files-script"
shareMountPoint="/mnt/azurefiles"


# Création du compte de stockage
az storage account create \
  --name $storageAccountName \
  --resource-group $resourceGroupName \
  --location $location \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot

# Création du partage Azure Files
az storage share create \
  --account-name $storageAccountName \
  --name $shareName \
  --quota 100

# Création de la machine virtuelle
az vm create \
  --resource-group $resourceGroupName \
  --name $vmName \
  --location $location \
  --image UbuntuLTS \
  --size $vmSize \
  --admin-username $adminUsername \
  --admin-password $adminPassword \
  --storage-account $storageAccountName \
  --custom-data cloud-init.txt \
  --generate-ssh-keys

# Connexion au partage Azure Files
sudo mkdir -p $shareMountPoint
sudo mount -t cifs //$storageAccountName.file.core.windows.net/$shareName $shareMountPoint -o vers=3.0,username=$storageAccountName,password=$(az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query '[0].value' -o tsv),dir_mode=0777,file_mode=0777,sec=ntlmssp

echo "Le partage Azure Files a été créé et la machine virtuelle a été créée avec succès."