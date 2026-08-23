# Outputing required info for users

/*
output "bridge_instance" {
  value = data.oci_core_instance.bridge_instance.display_name
}

output "Bridge_Instance_Public_IP" {
  value = data.oci_core_instance.bridge_instance.public_ip
}

output "Bridge_Instance_Private_IP" {
  value = data.oci_core_private_ips.BridgeInstancePrivateIP1.private_ips[0].ip_address
}

output "Bridge_Instance_Second_Private_IP" {
  value = data.oci_core_private_ips.BridgeInstancePrivateIP2.private_ips[0].ip_address
}

output "PrivateInstance1_Private_IP" {
  value = oci_core_instance.PrivateInstance.private_ip
}

output "PrivateInstance2_Private_IP" {
  value = oci_core_instance.PrivateInstance2.private_ip
}

output "BridgeInstanceVnicAttachmentPrimary" {
  value = data.oci_core_vnic_attachments.BridgeInstanceVnicAttachmentPrimary.vnic_attachments[0]
}

output "BridgeInstanceVnicAttachmentSecondary" {
  value = data.oci_core_vnic_attachments.BridgeInstanceVnicAttachmentSecondary.vnic_attachments[0]
}

*/