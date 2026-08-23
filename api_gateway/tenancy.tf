# Get the specified tenancy's information.
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

# Get all the region's information.
data "oci_identity_regions" "regions" {
}

# Get all the region's information and filter for home region
data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

data "oci_identity_regions" "current-region" {
  filter {
    name   = "name"
    values = [var.region]
  }
}

# Get all the ads's information for this tenancy.
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "objstore_svcs" {
  filter {
    name   = "cidr_block"
    values = [".*-objectstorage"]
    regex  = true
  }
}

data "oci_core_services" "all_svcs" {
  filter {
    name   = "cidr_block"
    values = [".*-services-in-oracle-services-network"]
    regex  = true
  }
}

data "oci_identity_compartments" "compartment" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = "true"
  access_level              = "ANY"

  filter {
    name   = "name"
    values = [var.compartment_name]
  }
}

locals {
  compartment_id = data.oci_identity_compartments.compartment.compartments[0].id
}