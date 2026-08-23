output "Instructions" {
    value = <<EOF
Terminal 1:
ssh -i ${var.ssh_private_key_path} opc@${oci_core_instance.instance-adbwork.public_ip}
sudo tcpdump -nni enp0s5 'dst host ${oci_core_instance.instance-adbwork.private_ip} and tcp dst port 22 and tcp[tcpflags] & tcp-syn != 0'

Verify the outputs

With firewall_policy_2:
02:48:01.036052 IP 10.0.3.230.51502 > 192.168.1.69.22: Flags [S], seq 2294494962, win 62720, options [mss 8924,sackOK,TS val 2252038417 ecr 0,nop,wscale 7], length 0

With firewall_policy_1:
01:08:51.771979 IP 10.0.2.210.10413 > 192.168.1.69.22: Flags [S], seq 173505504, win 62720, options [mss 8924,sackOK,TS val 2246089153 ecr 0,nop,wscale 7], length 0


Terminal 2:
ssh -i ${var.ssh_private_key_path} opc@${oci_core_instance.public_instance.public_ip}
Copy ${var.ssh_private_key_path} ~/.ssh/lcm
ssh -i ~/.ssh/lcm opc@${oci_core_instance.private_instance.private_ip}
nc -vz -w 5 ${oci_core_instance.instance-adbwork.private_ip} 22

EOF
  
}

output "firewall_nat_ips" {
  value = oci_network_firewall_network_firewall.network_firewall.nat_configuration
}