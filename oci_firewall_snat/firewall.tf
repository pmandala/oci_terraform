# OCI Network Firewall Policy deny all
resource "oci_network_firewall_network_firewall_policy" "firewall_policy_deny" {
  display_name   = "firewall_policy-deny-all"
  compartment_id = var.compartment_ocid
}


# OCI Network Firewall
resource "oci_network_firewall_network_firewall" "network_firewall" {
  compartment_id             = var.compartment_ocid
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy_2.id
  subnet_id                  = oci_core_subnet.firewall_subnet.id
  display_name               = "firewall-1"

  nat_configuration {
    must_enable_private_nat = true
  }

  depends_on = [
    oci_core_subnet.firewall_subnet
  ]
}

data "oci_core_private_ips" "firewall_ip_ocid" {
  subnet_id  = oci_core_subnet.firewall_subnet.id
  ip_address = oci_network_firewall_network_firewall.network_firewall.ipv4address
}
