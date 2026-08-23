# OCI Network Firewall Policy 2
resource "oci_network_firewall_network_firewall_policy" "firewall_policy_2" {
  display_name   = "firewall_policy-2"
  compartment_id = var.compartment_ocid
  description = "Policy with No SNAT"
}

# Address Lists

resource "oci_network_firewall_network_firewall_policy_address_list" "firewall_policy_2_address_list_1" {
  name                       = "firewall_vcn"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_2.id
  type                       = "IP"
  addresses                  = ["10.0.3.230/32"]
}

resource "oci_network_firewall_network_firewall_policy_address_list" "firewall_policy_2_address_list_2" {
  name                       = "adbs_vcn"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_2.id
  type                       = "IP"
  addresses                  = ["192.168.1.69/32"]
}

resource "oci_network_firewall_network_firewall_policy_address_list" "firewall_policy_2_address_list_3" {
  name                       = "ODB_IP"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_2.id
  type                       = "IP"
  addresses                  = ["10.62.0.10"]
}

resource "oci_network_firewall_network_firewall_policy_address_list" "firewall_policy_2_address_list_4" {
  name                       = "ADBS_CIDR"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_2.id
  type                       = "IP"
  addresses                  = ["10.0.0.0/16"]
}


# SERVICES

resource "oci_network_firewall_network_firewall_policy_service" "firewall_policy_2_service_1" {
  name                       = "ssh-service"
  type                       = "TCP_SERVICE"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_2.id
  port_ranges {
    minimum_port = 22
  }
  port_ranges {
    minimum_port = 443
  }
}


# SERVICE LIST

resource "oci_network_firewall_network_firewall_policy_service_list" "firewall_policy_2_service_list_1" {
  name                       = "ssh-service"
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_2.id
  services                   = [oci_network_firewall_network_firewall_policy_service.firewall_policy_2_service_1.name]
}


# SECURITY RULES


resource "oci_network_firewall_network_firewall_policy_security_rule" "firewall_policy_2_security_rule_1" {
  lifecycle {
    ignore_changes = [position]
  }
  action = "ALLOW"
  name   = "ssh"
  condition {
    application         = []
    destination_address = []
    service             = [oci_network_firewall_network_firewall_policy_service.firewall_policy_2_service_1.name]
    source_address      = []
    url                 = []
  }
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_2.id
}
