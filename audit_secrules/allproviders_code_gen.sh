#!/bin/bash

set -e
# set -x

mkdir -p ./.tmp

generateAllRegionProviders () {
    touch allproviders.tf
    echo "" > allproviders.tf
    
    oci iam region-subscription list --all | jq -r '.' > ./.tmp/region_subscriptions.json
    for region in $(jq -c '.data[]' < ./.tmp/region_subscriptions.json)
    do 
        echo "$region"; 
        regionKey=$(echo $region | jq -r '."region-key" | ascii_downcase')
        regionName=$(echo $region | jq -r '."region-name"')
        isHomeRegion=$(echo $region | jq -r '."is-home-region"')
        # provider
        cat <<EOF >> allproviders.tf
provider "oci" {
  alias            = "$regionKey"
  region           = "$regionName"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

EOF
    done

    # cat allproviders.tf
}

# generate all region providers for these
generateAllRegionProviders

echo "All provider tf code generated !!!"
