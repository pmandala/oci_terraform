
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


  # process the security rules
  security_rules_merged_list = flatten([for obj in data.oci_core_security_lists.security_lists.security_lists :

    concat(
      flatten([for egress_rules in obj.egress_security_rules :
        merge(egress_rules, {
          "direction"          = "EGRESS",
          "display_name"       = obj.display_name,
          "vcn_id"             = obj.vcn_id,
          "seclist_id"         = obj.id,
          "vcn_display_name"   = lookup(local.vcnid_name_map, obj.vcn_id),
          "stateless"          = egress_rules.stateless ? "Yes" : "No",
          "icmp_options"       = join(",", [for opt in egress_rules.icmp_options : format("type=%s, code=%s", opt.type, opt.code)]),
          "tcp_options"        = join(",", [for opt in egress_rules.tcp_options : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
          "udp_options"        = join(",", [for opt in egress_rules.udp_options : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
          "tcp_options_source" = join(",", [for opt in flatten(egress_rules.tcp_options.*.source_port_range) : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
          "udp_options_source" = join(",", [for opt in flatten(egress_rules.udp_options.*.source_port_range) : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
          "protocol"           = var.decode_protocol[egress_rules.protocol]
        })
      ]),
      flatten([for ingress_rules in obj.ingress_security_rules :
        merge(ingress_rules, {
          "direction"          = "INGRESS",
          "display_name"       = obj.display_name,
          "vcn_id"             = obj.vcn_id,
          "seclist_id"         = obj.id,
          "vcn_display_name"   = lookup(local.vcnid_name_map, obj.vcn_id),
          "stateless"          = ingress_rules.stateless ? "Yes" : "No",
          "icmp_options"       = join(",", [for opt in ingress_rules.icmp_options : format("type=%s, code=%s", opt.type, opt.code)]),
          "tcp_options"        = join(",", [for opt in ingress_rules.tcp_options : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
          "udp_options"        = join(",", [for opt in ingress_rules.udp_options : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
          "tcp_options_source" = join(",", [for opt in flatten(ingress_rules.tcp_options.*.source_port_range) : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
          "udp_options_source" = join(",", [for opt in flatten(ingress_rules.udp_options.*.source_port_range) : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
          "protocol"           = var.decode_protocol[ingress_rules.protocol]
        })
      ])
    )

  ])


  # security list csv formatted output
  security_rules_output_list = flatten([for obj in local.security_rules_merged_list :
    join(",", ["Security List",
      obj.vcn_display_name,
      obj.display_name,
      obj.direction,
      obj.stateless,
      lookup(obj, "source_type", lookup(obj, "destination_type", "")),
      lookup(obj, "source", lookup(obj, "destination", "")),
      obj.protocol,
      obj.tcp_options_source != "" ? obj.tcp_options_source : (obj.udp_options_source != "" ? obj.udp_options_source : (obj.protocol != "ICMP" ? "All" : "")),
      obj.tcp_options != "" ? obj.tcp_options : (obj.udp_options != "" ? obj.udp_options : (obj.protocol != "ICMP" ? "All" : "")),
      "\"${obj.icmp_options != "" ? obj.icmp_options : (obj.protocol == "ICMP" ? "All" : "")}\"",
      "\"${obj.description}\"",
      obj.seclist_id
    ])
  ])


  # process the network security lists
  nsg_merged_list = flatten([for obj in data.oci_core_network_security_groups.nsgs.network_security_groups :

    flatten([for rules in data.oci_core_network_security_group_security_rules.nsg_security_rules[obj.id].security_rules :
      merge(rules, {
        "nsg_id"             = obj.id,
        "nsg_display_name"   = obj.display_name
        "vcn_id"             = obj.vcn_id,
        "vcn_display_name"   = lookup(local.vcnid_name_map, obj.vcn_id),
        "stateless"          = rules.stateless ? "Yes" : "No",
        "source"             = rules.source_type == "NETWORK_SECURITY_GROUP" ? lookup(local.nsgid_name_map, rules.source) : rules.source,
        "destination"        = rules.destination_type == "NETWORK_SECURITY_GROUP" ? lookup(local.nsgid_name_map, rules.destination) : rules.destination,
        "icmp_options"       = join(",", [for opt in rules.icmp_options : format("type=%s, code=%s", opt.type, opt.code)]),
        "udp_options_source" = join(",", [for opt in flatten(rules.udp_options.*.source_port_range) : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
        "udp_options_dest"   = join(",", [for opt in flatten(rules.udp_options.*.destination_port_range) : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
        "tcp_options_source" = join(",", [for opt in flatten(rules.tcp_options.*.source_port_range) : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
        "tcp_options_dest"   = join(",", [for opt in flatten(rules.tcp_options.*.destination_port_range) : (opt.min != opt.max ? format("%s-%s", opt.min, opt.max) : opt.min)]),
        "protocol"           = var.decode_protocol[rules.protocol]
      })
    ])

  ])

  # nsg csv formatted output
  nsg_output_list = flatten([for obj in local.nsg_merged_list :
    join(",", ["NSG",
      obj.vcn_display_name,
      obj.nsg_display_name,
      obj.direction,
      obj.stateless,
      obj.source_type != "" ? obj.source_type : obj.destination_type,
      obj.source != "" ? obj.source : obj.destination,
      obj.protocol,
      obj.tcp_options_source != "" ? obj.tcp_options_source : (obj.udp_options_source != "" ? obj.udp_options_source : (obj.protocol != "ICMP" ? "All" : "")),
      obj.tcp_options_dest != "" ? obj.tcp_options_dest : (obj.udp_options_dest != "" ? obj.udp_options_dest : (obj.protocol != "ICMP" ? "All" : "")),
      "\"${obj.icmp_options != "" ? obj.icmp_options : (obj.protocol == "ICMP" ? "All" : "")}\"",
      "\"${obj.description}\"",
      obj.nsg_id
    ])
  ])

}


