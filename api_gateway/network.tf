# Number of subnets
locals {
  timestamp        = timestamp()
  vcn_dns_label    = "vanityurl"
  vcn_display_name = format("%s-%s", local.vcn_dns_label, formatdate("YYYYMMDDhhmmss", local.timestamp))
  subnet_name      = "apigateway"
}

resource "oci_core_virtual_network" "vcn1" {
  cidr_block     = var.cidr_block
  compartment_id = local.compartment_id
  display_name   = lower(local.vcn_display_name)
  dns_label      = lower(local.vcn_dns_label)
}


resource "oci_core_internet_gateway" "igw_service" {
  compartment_id = oci_core_virtual_network.vcn1.compartment_id
  display_name   = "igw"
  vcn_id         = oci_core_virtual_network.vcn1.id
}

resource "oci_core_default_route_table" "route_table" {
  manage_default_resource_id = oci_core_virtual_network.vcn1.default_route_table_id
  display_name               = "api_route_table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw_service.id
  }
}

resource "oci_core_service_gateway" "sgw_service" {
  compartment_id = oci_core_virtual_network.vcn1.compartment_id
  services {
    service_id = data.oci_core_services.all_svcs.services[0].id
  }
  vcn_id       = oci_core_virtual_network.vcn1.id
  display_name = "sgw"
}


resource "oci_core_nat_gateway" "ngw_service" {
  compartment_id = oci_core_virtual_network.vcn1.compartment_id
  vcn_id         = oci_core_virtual_network.vcn1.id
  display_name   = "ngw"
}

resource "oci_core_subnet" "sub_api_gateway" {
  cidr_block        = cidrsubnet(var.cidr_block, 6, 1)
  display_name      = lower(local.subnet_name)
  dns_label         = lower(local.subnet_name)
  compartment_id    = oci_core_virtual_network.vcn1.compartment_id
  vcn_id            = oci_core_virtual_network.vcn1.id
  route_table_id    = oci_core_default_route_table.route_table.id
  dhcp_options_id   = oci_core_virtual_network.vcn1.default_dhcp_options_id
  security_list_ids = [oci_core_virtual_network.vcn1.default_security_list_id, oci_core_security_list.sec_api_gateway.id]
}

resource "oci_core_security_list" "sec_api_gateway" {
  compartment_id = oci_core_virtual_network.vcn1.compartment_id
  vcn_id         = oci_core_virtual_network.vcn1.id
  display_name   = "sec-api-gateway"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}