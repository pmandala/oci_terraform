# genric provider is used to interact with the many resources supported by the OCI
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  # OR We can use profile from ~/.oci/config
  #config_file_profile = "${var.config_file_profile}"
}

# creating home region provider
provider "oci" {
  alias            = "home"
  region           = lookup(data.oci_identity_regions.home-region.regions[0], "name")
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

