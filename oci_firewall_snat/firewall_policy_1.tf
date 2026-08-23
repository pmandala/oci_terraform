# OCI Network Firewall Policy 1
resource "oci_network_firewall_network_firewall_policy" "firewall_policy_1" {
  display_name   = "firewall_policy-1"
  compartment_id = var.compartment_ocid
  description = "Policy with SNAT"
}

# Address Lists

resource "oci_network_firewall_network_firewall_policy_address_list" "firewall_policy_1_address_list_1" {
  name                       = "firewall_subnet_cidr"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
  type                       = "IP"
  addresses                  = ["10.0.3.230/32"]
}

resource "oci_network_firewall_network_firewall_policy_address_list" "firewall_policy_1_address_list_2" {
  name                       = "hub_subnet_cidr"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
  type                       = "IP"
  addresses                  = ["192.168.1.0/24"]
}

resource "oci_network_firewall_network_firewall_policy_address_list" "firewall_policy_1_address_list_3" {
  name                       = "AZ_whitelist"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
  type                       = "IP"
  addresses                  = ["10.62.1.20"]
}

resource "oci_network_firewall_network_firewall_policy_address_list" "firewall_policy_1_address_list_4" {
  name                       = "adbs_vcn_cidr"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
  type                       = "IP"
  addresses                  = ["10.0.0.0/16"]
}


# SERVICES

resource "oci_network_firewall_network_firewall_policy_service" "firewall_policy_1_service_1" {
  name                       = "ssh-service"
  type                       = "TCP_SERVICE"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
  port_ranges {
    minimum_port = 22
  }
  port_ranges {
    minimum_port = 443
  }
}


# SERVICE LIST

resource "oci_network_firewall_network_firewall_policy_service_list" "firewall_policy_1_service_list_1" {
  name                       = "ssh-service"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
  services                   = [oci_network_firewall_network_firewall_policy_service.firewall_policy_1_service_1.name]
}


# SECURITY RULES


resource "oci_network_firewall_network_firewall_policy_security_rule" "firewall_policy_1_security_rule_1" {
  lifecycle {
    ignore_changes = [position]
  }
  action = "ALLOW"
  name   = "ssh"
  condition {
    application         = []
    destination_address = []
    service             = [oci_network_firewall_network_firewall_policy_service.firewall_policy_1_service_1.name]
    source_address      = []
    url                 = []
  }
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
}


# NAT RULES

resource "oci_network_firewall_network_firewall_policy_nat_rule" "firewall_policy_1_nat_rule_1" {
  action = "DIPP_SRC_NAT"
  condition {
    destination_address = [oci_network_firewall_network_firewall_policy_address_list.firewall_policy_1_address_list_2.name]
    service             = null
    source_address      = [oci_network_firewall_network_firewall_policy_address_list.firewall_policy_1_address_list_1.name]
  }
  name                       = "firewall_vcn_hub_snat"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
  type                       = "NATV4"
}

/*resource "oci_network_firewall_network_firewall_policy_nat_rule" "firewall_policy_1_nat_rule_2" {
  action = "DIPP_SRC_NAT"
  condition {
    destination_address = [oci_network_firewall_network_firewall_policy_address_list.firewall_policy_1_address_list_3.name]
    service             = null
    source_address      = [oci_network_firewall_network_firewall_policy_address_list.firewall_policy_1_address_list_4.name]
  }
  name                       = "firewall_vcn_odb_snat"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_1.id
  type                       = "NATV4"
}
*/