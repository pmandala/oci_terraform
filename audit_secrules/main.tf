
module "phx_audit" {
  source       = "./audit"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
}

module "iad_audit" {
  source       = "./audit"
  tenancy_ocid = var.tenancy_ocid
  region       = "us-ashburn-1"

  providers = {
    oci = oci.iad
  }
}