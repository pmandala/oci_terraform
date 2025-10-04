locals {
  deployment_display_name = "myadbs"
  deployment_path_prefix  = var.deployment_path_prefix
  adb_dns_name            = var.adb_dns_name
  gateway_display_name    = format("%s-gateway", var.gateway_display_name)
}


resource "oci_apigateway_gateway" "vanity_gateway" {
  compartment_id = local.compartment_id
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.sub_api_gateway.id
  display_name   = local.gateway_display_name
  certificate_id = oci_apigateway_certificate.vanity_certificate.id
}

resource "oci_apigateway_deployment" "adbs_deployment" {
  compartment_id = local.compartment_id
  gateway_id     = oci_apigateway_gateway.vanity_gateway.id
  display_name   = local.deployment_display_name
  path_prefix    = local.deployment_path_prefix

  specification {

    logging_policies {
      access_log {
        is_enabled = false
      }
      execution_log {
        is_enabled = false
      }
    }

    request_policies {
    }

    /*routes {
      backend {
        type                       = "HTTP_BACKEND"
        connect_timeout_in_seconds = 60.0
        is_ssl_verify_disabled     = false
        read_timeout_in_seconds    = 300.0
        send_timeout_in_seconds    = 10.0
        url                        = "https://${local.adb_dns_name}/oml/$${request.path[resource]}"
      }
      path    = "/oml/{resource*}"
      methods = ["ANY"]
      request_policies {
        header_transformations {
          set_headers {
            items {
              name      = "Host"
              values    = ["$${request.headers[host]}"]
              if_exists = "OVERWRITE"
            }
            items {
              name      = "x-adbs-host"
              values    = [local.adb_dns_name]
              if_exists = "OVERWRITE"
            }
          }
        }
      }
    }*/

    /*routes {
      backend {
        type                       = "HTTP_BACKEND"
        connect_timeout_in_seconds = 60.0
        is_ssl_verify_disabled     = false
        read_timeout_in_seconds    = 300.0
        send_timeout_in_seconds    = 10.0
        url                        = "https://${local.adb_dns_name}/omlusers/$${request.path[resource]}"
      }
      path    = "/omlusers/{resource*}"
      methods = ["ANY"]
      request_policies {
        header_transformations {
          set_headers {
            items {
              name      = "Host"
              values    = ["$${request.headers[host]}"]
              if_exists = "OVERWRITE"
            }
            items {
              name      = "x-adbs-host"
              values    = [local.adb_dns_name]
              if_exists = "OVERWRITE"
            }
          }
        }
      }
    }*/

    routes {
      backend {
        type                       = "HTTP_BACKEND"
        connect_timeout_in_seconds = 60.0
        is_ssl_verify_disabled     = false
        read_timeout_in_seconds    = 300.0
        send_timeout_in_seconds    = 10.0
        url                        = "https://${local.adb_dns_name}/ords/$${request.path[resource]}"
      }
      path    = "/ords/{resource*}"
      methods = ["ANY"]
      request_policies {
        header_transformations {
          set_headers {
            items {
              name      = "Host"
              values    = ["$${request.headers[host]}"]
              if_exists = "OVERWRITE"
            }
            items {
              name      = "x-adbs-host"
              values    = [local.adb_dns_name]
              if_exists = "OVERWRITE"
            }
          }
        }
      }
    }

    routes {
      backend {
        type                       = "HTTP_BACKEND"
        connect_timeout_in_seconds = 60.0
        is_ssl_verify_disabled     = false
        read_timeout_in_seconds    = 300.0
        send_timeout_in_seconds    = 10.0
        url                        = "https://${local.adb_dns_name}/i/$${request.path[resource]}"
      }
      path    = "/i/{resource*}"
      methods = ["ANY"]
    }

    routes {
      backend {
        type   = "STOCK_RESPONSE_BACKEND"
        status = 302
        headers {
          name  = "Location"
          value = "https://$${request.headers[host]}/ords/r/demo_user/askoracle102/home"
        }
      }
      path    = "/{any*}"
      methods = ["GET"]
      response_policies {
        header_transformations {
          set_headers {
            items {
              name      = "Location"
              values    = ["https://$${request.headers[host]}/ords/r/demo_user/askoracle102/home"]
              if_exists = "OVERWRITE"
            }
          }
        }
      }
    }

    /*routes {
      backend {
        type                       = "HTTP_BACKEND"
        connect_timeout_in_seconds = 60.0
        is_ssl_verify_disabled     = false
        read_timeout_in_seconds    = 300.0
        send_timeout_in_seconds    = 10.0
        url                        = "https://${local.adb_dns_name}/graphstudio/$${request.path[resource]}"
      }
      path    = "/graphstudio/{resource*}"
      methods = ["ANY"]
      request_policies {
        header_transformations {
          set_headers {
            items {
              name      = "Host"
              values    = ["$${request.headers[host]}"]
              if_exists = "OVERWRITE"
            }
            items {
              name      = "x-adbs-host"
              values    = [local.adb_dns_name]
              if_exists = "OVERWRITE"
            }
          }
        }
      }
    }

    /*routes {
      backend {
        type                       = "HTTP_BACKEND"
        connect_timeout_in_seconds = 60.0
        is_ssl_verify_disabled     = false
        read_timeout_in_seconds    = 300.0
        send_timeout_in_seconds    = 10.0
        url                        = "https://${local.adb_dns_name}/odi/$${request.path[resource]}"
      }
      path    = "/odi/{resource*}"
      methods = ["ANY"]
      request_policies {
        header_transformations {
          set_headers {
            items {
              name      = "Host"
              values    = ["$${request.headers[host]}"]
              if_exists = "OVERWRITE"
            }
            items {
              name      = "x-adbs-host"
              values    = [local.adb_dns_name]
              if_exists = "OVERWRITE"
            }
          }
        }
      }
    } */

    /*routes {
      backend {
        type                       = "HTTP_BACKEND"
        connect_timeout_in_seconds = 60.0
        is_ssl_verify_disabled     = false
        read_timeout_in_seconds    = 300.0
        send_timeout_in_seconds    = 10.0
        url                        = "https://${local.adb_dns_name}/broker/$${request.path[resource]}"
      }
      path    = "/broker/{resource*}"
      methods = ["ANY"]
      request_policies {
        header_transformations {
          set_headers {
            items {
              name      = "Host"
              values    = ["$${request.headers[host]}"]
              if_exists = "OVERWRITE"
            }
            items {
              name      = "x-adbs-host"
              values    = [local.adb_dns_name]
              if_exists = "OVERWRITE"
            }
          }
        }
      }
    }*/

  }
}

output "vanity_gateway_hostname" {
  value = oci_apigateway_gateway.vanity_gateway.hostname
}

output "vanity_gateway_public_ips" {
  value = oci_apigateway_gateway.vanity_gateway.ip_addresses.*.ip_address
}

output "vanity_gateway_url" {
  value = format("https://%s/<app context path>/", oci_apigateway_gateway.vanity_gateway.hostname)
}
