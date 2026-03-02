#!/bin/bash
#
#
# Usage:
# az-curl <host> <method> <request-uri> [extra-curl-args]
#
# ex:
# az-curl "$ACCOUNT.blob.core.windows.net" get "/?comp=list&maxresults=5000"
# az-curl "$ACCOUNT.blob.core.windows.net" get "/$CONTAINER_NAME?restype=container"
# az-curl "$ACCOUNT.blob.core.windows.net" get "/$CONTAINER_NAME?restype=container&comp=metadata"
# az-curl "$ACCOUNT.blob.core.windows.net" put "/$CONTAINER_NAME?restype=container&timeout=120" "-Dresp_headers.txt"
#


tfvars=(
  AZ_APP_ID
  AZ_PASSWORD
  AZ_TENANT_ID
)

for variable in "${tfvars[@]}"
do
  if [[ -z ${!variable+x} ]]; then
    echo "az-curl.sh: Missing export variable: $variable";
    # exit 1
  fi
done


function az-curl () {
    local APP_ID="${AZ_APP_ID}"
    local PASSWORD="${AZ_PASSWORD}"
    local TENANT_ID="${AZ_TENANT_ID}"

    local REQUEST_TIME="$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")"

    local HOST="$1"
    local HTTP_REQUEST_METHOD="$(echo "$2" | tr '[:lower:]' '[:upper:]')"
    local CANONICAL_URI="$3"
    local EXTRA_ARGS=("${@: 4}")

    local REQUEST_SERVICE
    if [[ "$HOST" == *"blob"* ]]; then
        REQUEST_SERVICE="storage"
    fi

    case $HTTP_REQUEST_METHOD in
        "GET")
            CUSTOM_HEADER_STR=""
            FORMATTER=" | xmllint --format - "
        ;;

        "PUT")
            CUSTOM_HEADER_STR=" -H content-length:0 "
        ;;
        
        *) 
            echo "Invalid HTTP Method"
            return
        ;;
    esac

    # service specific customizations
    case $REQUEST_SERVICE in
        "storage")
            export RESOURCE="https://storage.azure.com"
        ;;
        
        *) 
            echo "Request Service Not supported"
            return
        ;;
    esac

    export token=$(curl -X POST "https://login.microsoftonline.com/$TENANT_ID/oauth2/token" \
                -H 'Content-Type: application/x-www-form-urlencoded' \
                --data-urlencode "grant_type=client_credentials" \
                --data-urlencode "client_id=$APP_ID" \
                --data-urlencode "client_secret=$PASSWORD" \
                --data-urlencode "resource=$RESOURCE" -sS | jq -r '.access_token')

    # set -x 
    curl -sS "${EXTRA_ARGS[@]}" -X "$HTTP_REQUEST_METHOD"  $CUSTOM_HEADER_STR \
            -H "Authorization: Bearer $token" \
            -H "x-ms-version: 2026-02-06" \
            -H "x-ms-date: $REQUEST_TIME" \
            "https://$HOST$CANONICAL_URI" 
}



# FULL_STATUS_LINE=$(cat resp_headers.txt | head -n 1)

# echo "Full Status Line: $FULL_STATUS_LINE"

# # Extracting the status code and message using cut/awk
# STATUS_CODE=$(echo "$FULL_STATUS_LINE" | cut -d' ' -f2)
# STATUS_MESSAGE=$(echo "$FULL_STATUS_LINE" | cut -d' ' -f3-)

# echo "Status Code: $STATUS_CODE"
# echo "Status Message: $STATUS_MESSAGE"