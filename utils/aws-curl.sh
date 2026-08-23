#!/bin/bash
#
#
# Usage:
# aws-curl <host> <method> [file-to-send-as-body] <request-uri> [extra-curl-args]
#
# ex:
# aws-curl "s3.us-west-1.amazonaws.com" get "/"
# aws-curl "s3.us-west-1.amazonaws.com" get "/?bucket-region=us-west-1"
# aws-curl "s3.us-west-1.amazonaws.com" get "/?bucket-region=us-west-1&max-buckets=1000"
# aws-curl "testing-curl-1.s3.us-west-1.amazonaws.com" get "/"
# aws-curl "testing-curl-2.s3.us-west-1.amazonaws.com" put ./LocationConstraint.xml "/" "-Dresp_headers.txt"
#

tfvars=(
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_REGION
)

for variable in "${tfvars[@]}"
do
  if [[ -z ${!variable+x} ]]; then
    echo "aws-curl.sh: Missing export variable: $variable";
    # exit 1
  fi
done
 
function sha256_hash_in_hex(){
  a="$@"
  printf "$a" | openssl dgst -binary -sha256 | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//'
  
}

function hex_of_sha256_hmac_with_string_key_and_value {
  KEY=$1
  DATA="$2"
  shift 2
  printf "$DATA" | openssl dgst -binary -sha256 -hmac "$KEY" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//'
}

function hex_of_sha256_hmac_with_hex_key_and_value {
  KEY="$1"
  DATA="$2"
  shift 2
  printf "$DATA" | openssl dgst -binary -sha256 -mac HMAC -macopt "hexkey:$KEY" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//'
}

function sign() {
  STRING_TO_SIGN="$1"
  SECRET_ACCESS_KEY="$2"
  REQUEST_DATE="$3"
  REGION="$4"
  REQUEST_SERVICE="$5"
  shift 5

  DATE_HMAC=$(hex_of_sha256_hmac_with_string_key_and_value "AWS4${SECRET_ACCESS_KEY}" "${REQUEST_DATE}")
  REGION_HMAC=$(hex_of_sha256_hmac_with_hex_key_and_value "${DATE_HMAC}" "${REQUEST_REGION}")
  SERVICE_HMAC=$(hex_of_sha256_hmac_with_hex_key_and_value "${REGION_HMAC}" "${REQUEST_SERVICE}")
  SIGNING_HMAC=$(hex_of_sha256_hmac_with_hex_key_and_value "${SERVICE_HMAC}" "aws4_request")
  SIGNATURE=$(hex_of_sha256_hmac_with_hex_key_and_value "${SIGNING_HMAC}" "${STRING_TO_SIGN}")

  printf "${SIGNATURE}"
}

function create_canonical_request() {
  HTTP_REQUEST_METHOD="$1"
  CANONICAL_URI="$2"
  CANONICAL_QUERY_STRING="$3"
  CANONICAL_HEADERS="$4"
  SIGNED_HEADERS="$5"
  REQUEST_PAYLOAD_HASH_HEX="$6"
  shift 6

  CANONICAL_REQUEST_CONTENT="${HTTP_REQUEST_METHOD}\n${CANONICAL_URI}\n${CANONICAL_QUERY_STRING}\n${CANONICAL_HEADERS}\n\n${SIGNED_HEADERS}\n${REQUEST_PAYLOAD_HASH_HEX}"
  CANONICAL_REQUEST="$(sha256_hash_in_hex "${CANONICAL_REQUEST_CONTENT}")"

  printf "$CANONICAL_REQUEST"
}

function sign_canonical_request() {
  CANONICAL_REQUEST="$1"
  SECRET_ACCESS_KEY="$2"
  REQUEST_TIME="$3"
  REGION="$4"
  REQUEST_SERVICE="$5"
  shift 5

  REQUEST_DATE=$(printf "${REQUEST_TIME}" | cut -c 1-8)
  ALGORITHM=AWS4-HMAC-SHA256
  CREDENTIAL_SCOPE="${REQUEST_DATE}/${REQUEST_REGION}/${REQUEST_SERVICE}/aws4_request"
  STRING_TO_SIGN="${ALGORITHM}\n${REQUEST_TIME}\n${CREDENTIAL_SCOPE}\n${CANONICAL_REQUEST}"

  printf "$(sign "$STRING_TO_SIGN" "$SECRET_ACCESS_KEY" "$REQUEST_DATE" "$REGION" "$REQUEST_SERVICE")"
}

# Authorization: AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20110909/us-east-1/iam/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=ced6826de92d2bdeed8f846f0bf508e8559e98e4b0199114b84c54174deb456c
function create_authorization_header() {
  ACCESS_KEY_ID=$1
  SIGNATURE=$2
  REQUEST_TIME=$3
  REQUEST_REGION=$4
  REQUEST_SERVICE=$5
  SIGNED_HEADERS=$6
  shift 6

  REQUEST_DATE=$(printf "%s" "${REQUEST_TIME}" | cut -c 1-8)
  ALGORITHM="AWS4-HMAC-SHA256"
  # keyid/date/region/service/term
  CREDENTIAL_SCOPE="$ACCESS_KEY_ID/${REQUEST_DATE}/${REQUEST_REGION}/${REQUEST_SERVICE}/aws4_request"

  printf "$ALGORITHM \
Credential=$CREDENTIAL_SCOPE, \
SignedHeaders=$SIGNED_HEADERS, \
Signature=$SIGNATURE"
}

# url encode all special characters except "/", "?", "=", and "&"
function rawurlencode {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o	

  for (( pos=0 ; pos<strlen ; pos++ )); do
	c=${string:$pos:1}
	case "$c" in
		[-_.~a-zA-Z0-9] | "/" | "?" | "=" | "&" ) o="${c}" ;;
		* )               printf -v o '%%%02x' "'$c"
	esac
	encoded+="${o}"
	done

	echo "${encoded}"
}


function aws-curl () {
  local ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
  local SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
  local REQUEST_REGION="${AWS_REGION}"

  local HOST="$1"
  local HTTP_REQUEST_METHOD="$(echo "$2" | tr '[:lower:]' '[:upper:]')"

  local REQUEST_SERVICE
  if [[ "$HOST" == *"s3"* ]]; then
      REQUEST_SERVICE=s3
  fi

  # defaults
  local REQUEST_TIME="$(date -u +%Y%m%d'T'%H%M%S'Z')"
  local CANONICAL_HEADERS=""
  local SIGNED_HEADERS=""
  local CUSTOM_HEADER_STR=""
  local REQUEST_PAYLOAD=""
  local API_URL=""
  local EXTRA_ARGS
  local CANONICAL_URI
  local CANONICAL_QUERY_STRING=""
  local REQUEST_PAYLOAD_HASH_HEX=""
  local FORMATTER=""
  local BODY_ARG
  BODY_ARG=()

  case $HTTP_REQUEST_METHOD in
      "GET")
        if [[ "$3" == *'?'* ]]; then
          CANONICAL_URI="$(echo "$3" | cut -d '?' -f 1)"
          CANONICAL_QUERY_STRING="$(echo "$3" | cut -d '?' -f 2)"
          API_URL="https://$HOST$CANONICAL_URI?$CANONICAL_QUERY_STRING"
        else 
          CANONICAL_URI="$3"
          API_URL="https://$HOST$CANONICAL_URI"
        fi
        
        EXTRA_ARGS=("${@: 4}")
        CONTENT_TYPE="application/x-www-form-urlencoded"
        REQUEST_PAYLOAD_HASH_HEX=$(sha256_hash_in_hex "${REQUEST_PAYLOAD}")
        CUSTOM_HEADER_STR=" -H x-amz-content-sha256:$REQUEST_PAYLOAD_HASH_HEX "
        FORMATTER=" | xmllint --format - "
      ;;

      "PUT")
        REQUEST_PAYLOAD=$3
  		  CANONICAL_URI=$4
        EXTRA_ARGS=("${@: 5}")
        API_URL="https://$HOST$CANONICAL_URI"
        BODY_ARG=(--data-binary @${3})
        CONTENT_TYPE="$(file --mime-type $REQUEST_PAYLOAD | awk '{print $2}')"
        CONTENT_LENGTH="$(wc -c < $REQUEST_PAYLOAD | xargs)";
        REQUEST_PAYLOAD_HASH_HEX="$(openssl dgst -binary -sha256 < $REQUEST_PAYLOAD | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//')"
        CUSTOM_HEADER_STR=" -H x-amz-content-sha256:$REQUEST_PAYLOAD_HASH_HEX -H content-length:$CONTENT_LENGTH "
      ;;

      "DELETE")
        CANONICAL_URI="$3"
        API_URL="https://$HOST$CANONICAL_URI"
        EXTRA_ARGS=("${@: 4}")
        CONTENT_TYPE="application/x-www-form-urlencoded"
        CONTENT_LENGTH=0;
        REQUEST_PAYLOAD_HASH_HEX=$(sha256_hash_in_hex "${REQUEST_PAYLOAD}")
        CUSTOM_HEADER_STR=" -H x-amz-content-sha256:$REQUEST_PAYLOAD_HASH_HEX "
        FORMATTER=" | xmllint --format - "
      ;;
      
      *) 
        echo "Invalid HTTP Method"
        return
      ;;
  esac

  # service specific customizations
  case $REQUEST_SERVICE in
      "s3")
          CANONICAL_HEADERS="content-type:$CONTENT_TYPE; charset=utf-8\nhost:$HOST\nx-amz-content-sha256:$REQUEST_PAYLOAD_HASH_HEX\nx-amz-date:$REQUEST_TIME"
          SIGNED_HEADERS="content-type;host;x-amz-content-sha256;x-amz-date"
      ;;
      
      *) 
        echo "Request Service Not supported"
        return
      ;;
  esac

  local CANONICAL_REQUEST=$(create_canonical_request "$HTTP_REQUEST_METHOD" "$CANONICAL_URI" "$CANONICAL_QUERY_STRING" "$CANONICAL_HEADERS" "$SIGNED_HEADERS" "$REQUEST_PAYLOAD_HASH_HEX")
  local SIGNATURE=$(sign_canonical_request "$CANONICAL_REQUEST" "$SECRET_ACCESS_KEY" "$REQUEST_TIME" "$REQUEST_REGION" "$REQUEST_SERVICE")
  local AUTHORIZATION_HEADER=$(create_authorization_header "$ACCESS_KEY_ID" "$SIGNATURE" "$REQUEST_TIME" "$REQUEST_REGION" "$REQUEST_SERVICE" "$SIGNED_HEADERS")
  
  # set -x 
  curl -sS "${EXTRA_ARGS[@]}" "${BODY_ARG[@]}" \
      -X "$HTTP_REQUEST_METHOD" $CUSTOM_HEADER_STR \
      -H "host:$HOST" \
      -H "content-type:$CONTENT_TYPE; charset=utf-8" \
      -H "x-amz-date:$REQUEST_TIME" \
      -H "authorization:$AUTHORIZATION_HEADER" \
      -d "$REQUEST_PAYLOAD" "$API_URL"
}
