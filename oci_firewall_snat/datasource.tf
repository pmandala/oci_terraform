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
