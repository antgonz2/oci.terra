/* Output */

output "lb_public_ip" {
  value = ["${oci_load_balancer.inowlb1.ip_addresses}"]
}

output "Bastion_public_ip" {
  value = ["${oci_core_instance.Bastion01.*.public_ip}"]
}

output "InstancePrivateIPs" {
  value = ["${oci_core_instance.Bastion01.*.private_ip}"]
}
