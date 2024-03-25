data "oci_identity_compartments" "all-compartments" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = "true"
  access_level              = "ANY"
}

locals {
  comp_map = merge({ for i in range(length(data.oci_identity_compartments.all-compartments.compartments.*.id)) :
    data.oci_identity_compartments.all-compartments.compartments[i].id => data.oci_identity_compartments.all-compartments.compartments[i].name
  })

  all_comp_ids = data.oci_identity_compartments.all-compartments.compartments.*.id
}

/*output "all_compartments" {
  value = data.oci_identity_compartments.all-compartments.compartments.*.id
} */
