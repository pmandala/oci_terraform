variable "comp_id" {
  description = "Compartment OCID"
}

variable "decode_protocol" {
  default = {
    "6"   = "TCP"
    "1"   = "ICMP"
    "17"  = "UDP"
    "58"  = "ICMPv6"
    "all" = "All Protocols"
  }
}
