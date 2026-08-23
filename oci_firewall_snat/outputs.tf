
output "Instructions" {
    value = <<EOF
Terminal 1 (HUB):
ssh -i ${var.ssh_private_key_path} opc@${oci_core_instance.hub_instance.public_ip}
sudo tcpdump -nni enp0s5 'dst host ${oci_core_instance.hub_instance.private_ip} and tcp dst port 22 and tcp[tcpflags] & tcp-syn != 0'

Verify the outputs

With firewall_policy_2:
15:53:03.345279 IP ${oci_core_instance.private_instance.private_ip}.33818 > ${oci_core_instance.hub_instance.private_ip}.22: Flags [S], seq 1700170340, win 62720, options [mss 8924,sackOK,TS val 3759011815 ecr 0,nop,wscale 7], length 0

With firewall_policy_1:
01:08:51.771979 IP <ANY FIREWALL NAT IP>.10413 > ${oci_core_instance.hub_instance.private_ip}.22: Flags [S], seq 173505504, win 62720, options [mss 8924,sackOK,TS val 2246089153 ecr 0,nop,wscale 7], length 0


Terminal 2 (SPOKE):
ssh -i ${var.ssh_private_key_path} opc@${oci_core_instance.public_instance.public_ip}
Copy ${var.ssh_private_key_path} ~/.ssh/lcm
ssh -i ~/.ssh/lcm opc@${oci_core_instance.private_instance.private_ip}
nc -vz -w 5 ${oci_core_instance.hub_instance.private_ip} 22

EOF
  
}


output "firewall_nat_ips" {
  value = oci_network_firewall_network_firewall.network_firewall.nat_configuration
}