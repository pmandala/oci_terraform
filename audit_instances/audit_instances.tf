data "oci_identity_compartments" "all-compartments" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = "true"
  access_level              = "ANY"
}

locals {
  comp_map = merge({ for i in range(length(data.oci_identity_compartments.all-compartments.compartments.*.id)) :
    data.oci_identity_compartments.all-compartments.compartments[i].id => data.oci_identity_compartments.all-compartments.compartments[i].name
  })
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
    "ID",
    "Compartment OCID",
    "Compartment Name"
  ])

  all_comp_ids = data.oci_identity_compartments.all-compartments.compartments.*.id
}

module "audit" {
  count   = length(local.all_comp_ids)
  source  = "./instances"
  comp_id = local.all_comp_ids[count.index]
  comp_name = local.comp_map[local.all_comp_ids[count.index]]
}

resource "local_file" "instances_csv" {
  content  = join("\n", concat([local.header_output_list], flatten(module.audit.*.all_instances)))
  filename = "${path.root}/instances.csv"
}
