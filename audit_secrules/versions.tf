terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.34.0"
    }
  }

  required_version = ">= 0.13"
}
