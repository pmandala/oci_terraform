data "oci_identity_compartments" "all-compartments" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = "true"
  access_level              = "ANY"
}

/*output "all_compartments" {
  value = data.oci_identity_compartments.all-compartments.compartments.*.id
} */

locals {
  # csv formatted headers
  header_output_list = join(",", ["Type",
    "VCN",
    "Name",
    "Direction",
    "Stateless",
    "Source type/Destination type",
    "Source/Destination",
    "Protocol",
    "Source Ports",
    "Destination Ports",
    "Type and Code",
    "Description",
    "OCID"
  ])

  all_comp_ids  = data.oci_identity_compartments.all-compartments.compartments.*.id
}

module "audit" {
  count   = length(local.all_comp_ids)
  source  = "./security_rules"
  comp_id = local.all_comp_ids[count.index]
}

resource "local_file" "security_rules_csv" {
  content  = join("\n", concat([local.header_output_list], flatten(module.audit.*.all_security_list_rules), flatten(module.audit.*.all_nsg_security_rules)))
  filename = "${path.root}/sec_rules_audit.csv"
}
