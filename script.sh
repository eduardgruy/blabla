#!/bin/sh
rgname=$1
functionappname=$2
webappname=$3

echo "$rgname $functionappname $webappname" > &2
wget -O functions.zip 'https://storgluedeployment.blob.core.windows.net/artifacts/functions.zip?sp=r&st=2020-10-13T13:02:20Z&se=2022-10-13T21:02:20Z&spr=https&sv=2019-12-12&sr=b&sig=AZkZbkC6QV7d1Yr1MMHTo3IRx4KSKLzB8qemY6amWXQ%3D'

az functionapp deployment source config-zip \
--resource-group $rgname \
--name $functionappname \ 
--src functions.zip

wget -O 'logistics-app.zip' 'https://storgluedeployment.blob.core.windows.net/artifacts/logistics-app.zip?sp=r&st=2020-10-14T09:46:12Z&se=2022-10-14T17:46:12Z&spr=https&sv=2019-12-12&sr=b&sig=5kiJgiB0zV3F%2FHlhYNOSgYpjex%2Fzm8%2Fleywld%2FAwD2k%3D'

az webapp deployment source config-zip \
--resource-group $rgname \
--name $webappname \
--src logistics-app.zip


# az functionapp deployment source config-zip -g test2 -n \
# 'functtstdtjs3v2s6' --src ./functions.zip