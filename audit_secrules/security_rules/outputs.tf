
output "all_security_list_rules" {
  //value = data.oci_core_security_lists.security_lists.security_lists
  //value = local.security_rules_merged_list
  value = local.security_rules_output_list
}

/*
output "all_nsg_security_groups" {
  value = data.oci_core_network_security_groups.nsgs.network_security_groups
}
*/

output "all_nsg_security_rules" {
  //value = data.oci_core_network_security_group_security_rules.nsg_security_rules
  //value = local.security_rules_merged_list
  value = local.nsg_output_list
}
