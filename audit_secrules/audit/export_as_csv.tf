
locals {
  # csv formatted headers
  header_output_list = join(",", [
    "Compartment Name",
    "Type",
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
    "Created On",
    "OCID"
  ])
}

resource "local_file" "security_rules_csv" {
  content  = join("\n", concat([local.header_output_list], flatten(module.audit.*.all_security_list_rules), flatten(module.audit.*.all_nsg_security_rules)))
  filename = "${path.root}/csv/${var.region}-rules.csv"
}
