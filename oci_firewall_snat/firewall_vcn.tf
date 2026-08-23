resource "oci_core_virtual_network" "firewall_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "firewall_vcn"
}

# SECURITY LIST

resource "oci_core_default_security_list" "firewall_vcn_default_security_list" {
  manage_default_resource_id = oci_core_virtual_network.firewall_vcn.default_security_list_id

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
    source      = "10.0.0.0/16"
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

resource "oci_core_default_route_table" "firewall_vcn_default_route_table" {
  manage_default_resource_id = oci_core_virtual_network.firewall_vcn.default_route_table_id

  route_rules {
    network_entity_id = oci_core_local_peering_gateway.lpg_firewall_vcn.id
    destination       = "192.168.0.0/16"
    destination_type  = "CIDR_BLOCK"
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }

}

resource "oci_core_route_table" "rt_dummy" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.firewall_vcn.id
  display_name   = "rt_dummy"
}

resource "oci_core_route_table" "rt_nat" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.firewall_vcn.id
  display_name   = "rt_nat"

  route_rules {
    description       = "FIREWALL 10.0.2.16"
    destination       = "10.0.3.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.firewall_ip_ocid.private_ips[0].id
    route_type        = "STATIC"
  }
}

resource "oci_core_route_table" "rt_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.firewall_vcn.id
  display_name   = "rt_public"

  route_rules {
    #description       = "FIREWALL 10.0.2.16"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
    route_type        = "STATIC"
  }

  route_rules {
    #description       = "FIREWALL 10.0.2.16"
    destination       = "192.168.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.lpg_firewall_vcn.id
    route_type        = "STATIC"
  }
}

resource "oci_core_route_table" "rt_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.firewall_vcn.id
  display_name   = "rt_private"

  route_rules {
    description       = "FIREWALL 10.0.2.16"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.firewall_ip_ocid.private_ips[0].id
    route_type        = "STATIC"
  }
}

# GATEWAYS

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "igw"
  vcn_id         = oci_core_virtual_network.firewall_vcn.id
  route_table_id = oci_core_route_table.rt_dummy.id
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_ocid
  display_name   = "ngw"
  vcn_id         = oci_core_virtual_network.firewall_vcn.id
}

resource "oci_core_local_peering_gateway" "lpg_firewall_vcn" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.firewall_vcn.id
  display_name   = "lpg_firewall_vcn"
}

# SUBNETS

resource "oci_core_subnet" "public_subnet" {
  cidr_block                 = "10.0.1.0/24"
  display_name               = "public_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.firewall_vcn.id
  security_list_ids          = [oci_core_virtual_network.firewall_vcn.default_security_list_id]
  route_table_id             = oci_core_route_table.rt_public.id
  dhcp_options_id            = oci_core_virtual_network.firewall_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "firewall_subnet" {
  cidr_block                 = "10.0.2.0/24"
  display_name               = "firewall_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.firewall_vcn.id
  security_list_ids          = [oci_core_virtual_network.firewall_vcn.default_security_list_id]
  route_table_id             = oci_core_virtual_network.firewall_vcn.default_route_table_id
  dhcp_options_id            = oci_core_virtual_network.firewall_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = "10.0.3.0/24"
  display_name               = "private_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.firewall_vcn.id
  security_list_ids          = [oci_core_virtual_network.firewall_vcn.default_security_list_id]
  route_table_id             = oci_core_route_table.rt_private.id
  dhcp_options_id            = oci_core_virtual_network.firewall_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}