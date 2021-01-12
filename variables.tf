variable "domain_name" {
  description = "The name of the top level domain"
  type        = string
  default     = "internal"
}

variable "vault_root_ca" {
  description = "A map containing root ca parameters"
  type        = map(any)
  default = {
    type                 = "internal"
    common_name          = "Root CA"
    ttl                  = "3650d"
    format               = "pem"
    private_key_format   = "der"
    key_type             = "rsa"
    key_bits             = 4096
    exclude_cn_from_sans = true
    ou                   = "Operations"
    organization         = "Internal Org"
  }
}

variable "vault_intermediate_ca" {
  description = "A map containing intermedite ca parameters"
  type        = map(any)
  default = {
    type                 = "internal"
    common_name          = "Intermediate CA"
    ttl                  = "1825d"
    format               = "pem"
    private_key_format   = "der"
    key_type             = "rsa"
    key_bits             = 4096
    exclude_cn_from_sans = true
    ou                   = "Operations"
    organization         = "Internal Org"
  }
}

variable "vault_infra_ca" {
  description = "A map containing infra ca parameters"
  type        = map(any)
  default = {
    type                 = "internal"
    common_name          = "Infra CA"
    ttl                  = "730d"
    format               = "pem"
    private_key_format   = "der"
    key_type             = "rsa"
    key_bits             = 4096
    exclude_cn_from_sans = true
    ou                   = "Operations"
    organization         = "Internal Org"
  }
}

