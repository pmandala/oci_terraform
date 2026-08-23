data "oci_core_images" "selected_image" {
  compartment_id = var.compartment_ocid
  #operating_system         = "Oracle Linux"
  #operating_system_version = 9
  shape = "VM.Standard.E5.Flex"

  filter {
    name   = "display_name"
    values = ["Oracle-Linux-9*"]
    regex  = true
  }
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_shapes" "shape" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")

  filter {
    name   = "name"
    values = [var.shape]
  }
}

locals {
  shape_cfgs = {
    for s in data.oci_core_shapes.shape.shapes : s.name => {
      "memory_in_gbs" = s.memory_in_gbs
      "ocpus"         = s.ocpus
    }
  }
}