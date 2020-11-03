#!/bin/bash
RG_NAME=$1
FUNCTION_APP_NAME=$2
WEB_APP_NAME=$3
EVH_CONNECTION_STRING=$4


get_sas_token() {
    local EVENTHUB_URI=$1
    local SHARED_ACCESS_KEY_NAME=$2
    local SHARED_ACCESS_KEY=$3
    local EXPIRY=${EXPIRY:=$((60 * 60 * 24))} # Default token expiry is 1 day

    local ENCODED_URI=$(echo -n $EVENTHUB_URI | jq -s -R -r @uri)
    local TTL=$(($(date +%s) + $EXPIRY))
    local UTF8_SIGNATURE=$(printf "%s\n%s" $ENCODED_URI $TTL | iconv -t utf8)

    local HASH=$(echo -n "$UTF8_SIGNATURE" | openssl sha256 -hmac $SHARED_ACCESS_KEY -binary | base64)
    local ENCODED_HASH=$(echo -n $HASH | jq -s -R -r @uri)

    echo -n "SharedAccessSignature sr=$ENCODED_URI&sig=$ENCODED_HASH&se=$TTL&skn=$SHARED_ACCESS_KEY_NAME"
}

echo "$RG_NAME $FUNCTION_APP_NAME $WEB_APP_NAME" 1>&2
wget -O 'functions.zip' 'https://storgluedeployment.blob.core.windows.net/artifacts/functions.zip?sp=r&st=2020-10-13T13:02:20Z&se=2022-10-13T21:02:20Z&spr=https&sv=2019-12-12&sr=b&sig=AZkZbkC6QV7d1Yr1MMHTo3IRx4KSKLzB8qemY6amWXQ%3D'

az functionapp deployment source config-zip --resource-group $RG_NAME --name $FUNCTION_APP_NAME --src functions.zip

wget -O 'logistics-app.zip' 'https://storgluedeployment.blob.core.windows.net/artifacts/logistics-app.zip?sp=r&st=2020-10-14T09:46:12Z&se=2022-10-14T17:46:12Z&spr=https&sv=2019-12-12&sr=b&sig=5kiJgiB0zV3F%2FHlhYNOSgYpjex%2Fzm8%2Fleywld%2FAwD2k%3D'

az webapp deployment source config-zip --resource-group $RG_NAME --name $WEB_APP_NAME --src logistics-app.zip
az webapp config set -n $WEB_APP_NAME -g $RG_NAME --startup-file='pm2 serve /home/site/wwwroot/build --no-daemon'
az webapp restart -n $WEB_APP_NAME -g $RG_NAME

ENDPOINT=${EVH_CONNECTION_STRING%/;*}
URL=${ENDPOINT/"Endpoint=sb:"/"https:"}

TMP_KEYNAME=${EVH_CONNECTION_STRING#*SharedAccessKeyName=}
KEYNAME=${TMP_KEYNAME%%;*}

TMP_KEY_VALUE=${EVH_CONNECTION_STRING#*SharedAccessKey=}
KEY_VALUE=${TMP_KEY_VALUE%%;*}

get_sas_token $URL $KEYNAME $KEY_VALUE | jq -c '{Result: map({id: .id})}' > output.txt
