# Provider Info
variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

/*variable "config_file_profile" {
}*/

#

variable "region" {
}

variable "compartment_name" {
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  description = "CIDR Block for VCN"
}

variable "deployment_path_prefix" {
}

variable "adb_dns_name" {
}