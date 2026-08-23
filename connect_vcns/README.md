# Connect VCNS using mutiple VNICS

This example creates 2 VCNs with non-overlapping subnets and establishes connectivity between the 2 using attached VNICs.

Each VCN has a public subnet and a private subnet. Each subnet is created with a separate security list and route table. 
The template then launches a private instance in each one of the private subnets.

A public instance is created in the public subnet of the first VCN. 
The public instance is configured as a Bridge instance (by enabling and configuring firewall to do forwarding).

The first VCN's private subnet's route table is configured to use the Bridge instance's private IP address as the default route target. See [Using a Private IP as a Route Target](https://docs.us-phoenix-1.oraclecloud.com/Content/Network/Tasks/managingroutetables.htm#privateip) for more details on this feature.

A secondary VNIC is created and attached to the Bridge instance. See [Configuring and using Secondary VNIC](https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/managingVNICs.htm) for more details on this feature. This secondary VNIC is attached to the public subnet of the second VCN. Now the Brdige instance has 2 VNICs, 1 is a default VNIC attached to the first VCN and other is the secondary VNIC attached to the second VCN.

The second VCN's private subnet's route table is configured to use the Bridge instance's secondary VNIC's private IP address as default route target. 

![Architecture diagram](images/connect_vcns_using_multiple_vnics.png)

[Reference](https://blogs.oracle.com/cloud-infrastructure/connecting-vcns-by-using-multiple-vnics-part-1)

### How to validate this example
Steps to validate this example will also be listed in the output when the terraform is deployed. 
1. Enable ssh forwarding from your machine by performing "ssh-add ~/.ssh/id_rsa"
2. Login to Bridge instance using command "ssh -A Bridge-Instance-Public-IP-Address"
3. After that, login to privateInstance-1 using "ssh PrivateInstance-1-IP-Address"
4. Ping the other PrivateInstance-2 "ping PrivateInstance-2-IP-Address"
5. Vice versa should work fine as well.

