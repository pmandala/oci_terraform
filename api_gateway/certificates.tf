resource "random_id" "random_cert_name" {
  keepers = {
    id = sha1(file("${path.root}/certs/adbs.oraclecorp.com.crt"))
  }

  byte_length = 1
}

resource "oci_apigateway_certificate" "vanity_certificate" {
  display_name              = format("%s-%s", "myCert", random_id.random_cert_name.id)
  compartment_id            = local.compartment_id
  intermediate_certificates = file("${path.root}/certs/root.oraclecorp.com.crt")
  certificate               = file("${path.root}/certs/adbs.oraclecorp.com.crt")
  private_key               = file("${path.root}/certs/adbs.oraclecorp.com.key")

  lifecycle {
    create_before_destroy = true
  }
}
