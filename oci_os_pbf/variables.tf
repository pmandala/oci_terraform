variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "home_region" {}


variable "source_bucket_name" {
  type    = string
  default = "incoming-zip-files-bucket"
}

variable "dest_bucket_name" {
  type    = string
  default = "extracted-files-destination-bucket"
}