

data "oci_core_instances" "all_instances" {
  compartment_id = var.comp_id
}

data "oci_core_vnic_attachments" "vnic_attachments" {
  for_each       = toset(data.oci_core_instances.all_instances.instances.*.id)
  compartment_id = var.comp_id
  instance_id    = each.key
}

data "oci_core_vnic" "vnic" {
  for_each = toset(data.oci_core_instances.all_instances.instances.*.id)
  vnic_id  = lookup(data.oci_core_vnic_attachments.vnic_attachments[each.key].vnic_attachments[0], "vnic_id")
}


locals {
  # csv formatted headers
  header_output_list = join(",", [
    "Name",
    "State",
    "Public IP",
    "Private IP",
    "Shape",
    "OCPU Count",
    "Memory (GB)",
    "GPU Count",
    "Region",
    "AD",
    "FD",
    "Created On",
    "OCID",
    "Compartment OCID"
  ])


  # instances csv formatted output
  instances_output_list = flatten([for obj in data.oci_core_instances.all_instances.instances :
    join(",", [
      obj.display_name,
      obj.state,
      lookup(data.oci_core_vnic.vnic[obj.id], "public_ip_address") == null ? "" : lookup(data.oci_core_vnic.vnic[obj.id], "public_ip_address"),
      lookup(data.oci_core_vnic.vnic[obj.id], "private_ip_address", ""),
      obj.shape,
      lookup(obj.shape_config[0], "ocpus", ""),
      lookup(obj.shape_config[0], "memory_in_gbs", ""),
      lookup(obj.shape_config[0], "gpus", ""),
      obj.region,
      obj.availability_domain,
      obj.fault_domain,
      obj.time_created,
      obj.id,
      obj.compartment_id
    ])
  ])


}

/*
output "count_all_instances" {
  value = length(local.all_instances)
}

output "vnics" {
  value = data.oci_core_vnic.vnic
}*/

