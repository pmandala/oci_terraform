variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "ssh_public_key_path" {}
variable "ssh_private_key_path" {}

variable "shape" {
  default = "VM.Standard.E5.Flex"
}