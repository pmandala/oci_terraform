
data "oci_core_vcns" "all_vcns" {
  compartment_id = var.comp_id
}

data "oci_core_security_lists" "security_lists" {
  compartment_id = var.comp_id
}

data "oci_core_network_security_groups" "nsgs" {
  compartment_id = var.comp_id
}

data "oci_core_network_security_group_security_rules" "nsg_security_rules" {
  for_each                  = toset(data.oci_core_network_security_groups.nsgs.network_security_groups.*.id)
  network_security_group_id = each.key
}

locals {

  # vcn ocid => name
  vcnid_name_map = merge({ for obj in data.oci_core_vcns.all_vcns.virtual_networks :
    obj.id => obj.display_name
  })

  # nsg ocid => name
  nsgid_name_map = merge({ for obj in data.oci_core_network_security_groups.nsgs.network_security_groups :
    obj.id => obj.display_name
  })

}


