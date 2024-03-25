#
# $Header: pdbcs/no_ship_src/service/terraform/audit/versions.tf
#
# versions.tf
#
# Copyright (c) 2017, 2023, Oracle and/or its affiliates. 
#
#    NAME
#      versions.tf
#
#    DESCRIPTION
#      Manages minimum required Terraform Version
#
#    NOTES
#
#    MODIFIED   (MM/DD/YY)
#    pmandala    01/16/24 - Creation
#

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
  required_version = ">= 1.2.0"
}