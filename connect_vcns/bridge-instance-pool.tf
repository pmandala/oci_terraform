resource "oci_core_instance_configuration" "bridge_instance_configuration" {
  compartment_id = var.compartment_ocid
  display_name   = "BridgeInstance"

  instance_details {
    instance_type = "compute"

    launch_details {
      source_details {
        source_type = "image"
        image_id    = var.InstanceImageOCID[var.region]
      }

      create_vnic_details {
        skip_source_dest_check = true
        # hostname_label
      }

      compartment_id = var.compartment_ocid
      display_name   = "BridgeInstance"
      shape          = var.InstanceShape

      metadata = {
        ssh_authorized_keys = file(var.ssh_public_key_path)
        user_data           = base64encode(file("user_data.tpl"))
      }
    }

    secondary_vnics {
      display_name = "SecondaryVNIC"

      create_vnic_details {
        skip_source_dest_check = true
        assign_public_ip       = false
      }
    }
  }

  timeouts {
    create = "10m"
  }
}


resource "oci_core_instance_pool" "bridge_instance_pool" {
  display_name              = "BridgeInstancePool"
  compartment_id            = var.compartment_ocid
  instance_configuration_id = oci_core_instance_configuration.bridge_instance_configuration.id
  #instance_display_name_formatter = 
  #instance_hostname_formatter = 

  placement_configurations {
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")
    # VCN 1 MgmtSubnet
    primary_subnet_id   = oci_core_subnet.MgmtSubnet.id

    secondary_vnic_subnets {
      # VCN 2 MgmtSubnet
      subnet_id    = oci_core_subnet.MgmtSubnet2.id
      display_name = "SecondaryVNIC"
    }
  }

  size = 0
}

# Get Bridge instances object from instance pool

data "oci_core_instance_pool_instances" "bridge_instance_pool_instances" {
  depends_on          = [oci_core_instance_pool.bridge_instance_pool]
  compartment_id   = var.compartment_ocid
  instance_pool_id = oci_core_instance_pool.bridge_instance_pool.id
}


###### BRIDGE INSTANCE #########

/*

# get first instance
data "oci_core_instance" "bridge_instance" {
  instance_id = lookup(data.oci_core_instance_pool_instances.bridge_instance_pool_instances.instances[0], "id")
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
  vnic_id    = lookup(data.oci_core_vnic_attachments.BridgeInstanceVnicAttachmentPrimary.vnic_attachments[0], "vnic_id")
}

# Get the OCID of the secondary VNIC
data "oci_core_vnic" "BridgeInstanceVnic2" {
  vnic_id    = lookup(data.oci_core_vnic_attachments.BridgeInstanceVnicAttachmentSecondary.vnic_attachments[0], "vnic_id")
}

# Gets a list of private IPs on the second VNIC

data "oci_core_private_ips" "BridgeInstancePrivateIP1" {
  vnic_id    = data.oci_core_vnic.BridgeInstanceVnic1.id
}

data "oci_core_private_ips" "BridgeInstancePrivateIP2" {
  vnic_id    = data.oci_core_vnic.BridgeInstanceVnic2.id
}

# Configurations for setting up the secondary VNIC
resource "null_resource" "configure-secondary-vnic" {
  depends_on = [oci_core_instance_pool.bridge_instance_pool]

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
      "sudo chmod 777 /tmp/secondary_vnic_all_configure.sh",
      "sudo /tmp/secondary_vnic_all_configure.sh -c ${lookup(data.oci_core_private_ips.BridgeInstancePrivateIP2.private_ips[0], "id")}",
      "sudo ip route add ${var.vcn_cidr2} via ${oci_core_subnet.MgmtSubnet2.virtual_router_ip} dev ens5",
    ]
  }
}

output "bridge_instance_pool" {
  value = oci_core_instance_pool.bridge_instance_pool.size
}

*/


/*
resource "oci_core_private_ip" "BridgeInstancePrivateIP" {
  vnic_id      = data.oci_core_vnic.BridgeInstanceVnic1.id
  display_name = "BridgeInstancePrivateIP"
}
*/