data "oci_core_instances" "test_instances" {
  #Required
  compartment_id = "${var.compartment_ocid}"
}
