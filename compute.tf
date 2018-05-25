/* Get the ocid for image */
data "oci_core_images" "OLImageOCID-ol7" {
  compartment_id           = "${var.compartment_ocid}"
  operating_system         = "Oracle Linux"
  operating_system_version = "7.4"
}

/* Instances */

resource "oci_core_instance" "inowinst01" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "inow-web-inst1"

  /*image               = "${var.Image}" */
  shape          = "${var.shape}"
  subnet_id      = "${oci_core_subnet.WebSubnetAD1.id}"
  hostname_label = "inow-instance1"

  source_details {
    source_type = "image"
    source_id   = "${var.Image}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_auth_key}"
    user_data           = "${base64encode(var.user-data)}"
  }
}

resource "oci_core_instance" "inowinst02" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "inow-web-inst2"

  source_details {
    source_type = "image"
    source_id   = "${var.Image}"
  }

  shape          = "${var.shape}"
  subnet_id      = "${oci_core_subnet.WebSubnetAD2.id}"
  hostname_label = "inow-instance2"

  metadata {
    ssh_authorized_keys = "${var.ssh_auth_key}"
    user_data           = "${base64encode(var.user-data)}"
  }
}

variable "user-data" {
  default = <<EOF
#!/bin/bash -x
echo '################### webserver userdata begins #####################'
touch ~opc/userdata.`date +%s`.start
# echo '########## yum update all ###############'
# yum update -y
echo '########## basic webserver ##############'
yum install -y httpd
systemctl enable  httpd.service
systemctl start  httpd.service
echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
hostname >> /var/www/html/index.html
echo '' >> /var/www/html/index.html
cat /etc/os-release >> /var/www/html/index.html
echo '</code></pre></body></html>' >> /var/www/html/index.html
firewall-offline-cmd --add-service=http
systemctl enable  firewalld
systemctl restart  firewalld
touch ~opc/userdata.`date +%s`.finish
echo '################### webserver userdata ends #######################'
EOF
}

/* Bastion Hosts */

resource "oci_core_instance" "Bastion01" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "inow-Bastion-01"

  source_details {
    source_type = "image"
    source_id   = "${var.Image}"
  }

  shape     = "${var.shape}"
  subnet_id = "${oci_core_subnet.BastionSubnetAD1.id}"

  /* hostname_label = "inow-instance1" */

  metadata {
    ssh_authorized_keys = "${var.ssh_auth_key}"
  }
}
