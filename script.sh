#!/bin/sh

az eventhubs namespace authorization-rule keys list \
 --resource-group $1 \
 --namespace-name $2 \
 --name RootManageSharedAccessKey > $AZ_SCRIPTS_OUTPUT_PATH