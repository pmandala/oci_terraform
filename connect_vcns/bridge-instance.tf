
resource "oci_core_instance" "BridgeInstance" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "BridgeInstance"
  shape               = var.InstanceShape

  create_vnic_details {
    subnet_id              = oci_core_subnet.MgmtSubnet.id
    assign_public_ip       = true
    skip_source_dest_check = true
  }

  source_details {
    source_type = "image"
    source_id   = var.InstanceImageOCID[var.region]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(file("user_data.tpl"))
  }

  timeouts {
    create = "10m"
  }
}

resource "oci_core_vnic_attachment" "sec_pvt_vnic" {
  create_vnic_details {
    subnet_id              = oci_core_subnet.MgmtSubnet2.id
    skip_source_dest_check = true
    assign_public_ip       = false
  }
  instance_id  = oci_core_instance.BridgeInstance.id
  display_name = "SecondaryVNIC"
}

data "oci_core_instance" "bridge_instance" {
  instance_id = oci_core_instance.BridgeInstance.id
}

data "oci_core_vnic_attachments" "BridgeInstanceVnicAttachmentPrimary" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")
  instance_id         = data.oci_core_instance.bridge_instance.id

  filter {
    name = "subnet_id"

    values = [
      oci_core_subnet.MgmtSubnet.id
    ]
  }
}

data "oci_core_vnic_attachments" "BridgeInstanceVnicAttachmentSecondary" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")
  instance_id         = data.oci_core_instance.bridge_instance.id

  filter {
    name   = "subnet_id"
    values = [oci_core_subnet.MgmtSubnet2.id]
  }
}

# Get the OCID of the primary VNIC
data "oci_core_vnic" "BridgeInstanceVnic1" {
  vnic_id = lookup(data.oci_core_vnic_attachments.BridgeInstanceVnicAttachmentPrimary.vnic_attachments[0], "vnic_id")
}

# Get the OCID of the secondary VNIC
data "oci_core_vnic" "BridgeInstanceVnic2" {
  vnic_id = lookup(data.oci_core_vnic_attachments.BridgeInstanceVnicAttachmentSecondary.vnic_attachments[0], "vnic_id")
}

# Gets a list of private IPs on the second VNIC

data "oci_core_private_ips" "BridgeInstancePrivateIP1" {
  vnic_id = data.oci_core_vnic.BridgeInstanceVnic1.id
}

data "oci_core_private_ips" "BridgeInstancePrivateIP2" {
  vnic_id = data.oci_core_vnic.BridgeInstanceVnic2.id
}

# Configurations for setting up the secondary VNIC
resource "null_resource" "configure-secondary-vnic" {
  connection {
    type        = "ssh"
    user        = "opc"
    private_key = file(var.ssh_private_key_path)
    host        = data.oci_core_instance.bridge_instance.public_ip
    timeout     = "30m"
  }

  provisioner "file" {
    source      = "scripts/secondary_vnic_all_configure.sh"
    destination = "/tmp/secondary_vnic_all_configure.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "sudo chmod 777 /tmp/secondary_vnic_all_configure.sh",
      "sudo /tmp/secondary_vnic_all_configure.sh -c ${lookup(data.oci_core_private_ips.BridgeInstancePrivateIP2.private_ips[0], "id")}",
      "sudo ip route add ${var.vcn_cidr2} via ${oci_core_subnet.MgmtSubnet2.virtual_router_ip} dev ens5",
    ]
  }
}
