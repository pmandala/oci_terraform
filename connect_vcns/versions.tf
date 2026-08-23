terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.34.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }

  required_version = ">= 0.13"
}
