
resource "oci_core_virtual_network" "hub_vcn" {
  cidr_block     = "192.168.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "hub_vcn"
}

# SECURITY LIST

resource "oci_core_default_security_list" "hub_vcn_default_security_list" {
  manage_default_resource_id = oci_core_virtual_network.hub_vcn.default_security_list_id

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }
  ingress_security_rules {
    protocol    = "1"
    source      = "192.168.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 3
    }
  }
  ingress_security_rules {
    protocol    = "all"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
}

# ROUTE TABLES

resource "oci_core_default_route_table" "hub_vcn_default_route_table" {
  manage_default_resource_id = oci_core_virtual_network.hub_vcn.default_route_table_id

  route_rules {
    network_entity_id = oci_core_local_peering_gateway.lpg_hub_vcn.id
    destination       = "10.0.0.0/16"
    destination_type  = "CIDR_BLOCK"
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw_hub_vcn.id
  }

}

# GATEWAYS

resource "oci_core_internet_gateway" "igw_hub_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "igw"
  vcn_id         = oci_core_virtual_network.hub_vcn.id
}

resource "oci_core_local_peering_gateway" "lpg_hub_vcn" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.hub_vcn.id
  display_name   = "lpg_hub_vcn"
  peer_id        = oci_core_local_peering_gateway.lpg_firewall_vcn.id

  lifecycle {
    # ignore_changes = [peer_id]
  }
}

# SUBNETS

resource "oci_core_subnet" "hub_subnet" {
  cidr_block                 = "192.168.1.0/24"
  display_name               = "hub_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.hub_vcn.id
  security_list_ids          = [oci_core_virtual_network.hub_vcn.default_security_list_id]
  route_table_id             = oci_core_virtual_network.hub_vcn.default_route_table_id
  dhcp_options_id            = oci_core_virtual_network.hub_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
}
