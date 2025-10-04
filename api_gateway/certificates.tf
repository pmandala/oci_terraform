resource "oci_apigateway_certificate" "vanity_certificate" {
  display_name              = "myCert"
  compartment_id            = local.compartment_id
  intermediate_certificates = file("${path.root}/certs/root.oraclecorp.com.crt")
  certificate               = file("${path.root}/certs/adbs.oraclecorp.com.crt")
  private_key               = file("${path.root}/certs/adbs.oraclecorp.com.key")
}
