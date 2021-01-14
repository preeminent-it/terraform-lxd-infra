variable "domain_name" {
  description = "The name of the top level domain"
  type        = string
  default     = "internal"
}

variable "lxd_network" {
  description = "A map containing lxd network config"
  type        = map(any)
  default = {
    name         = "infra"
    ipv4_address = "10.150.19.1/24"
    ipv4_nat     = true
  }
}

variable "lxd_profile" {
  description = "A map containing lxd profile config"
  type = object({
    name    = string
    devices = map(any)
  })
  default = {
    name = "infra"
    devices = {
      nic = {
        name = "eno1"
        properties = {
          nictype = "bridged"
          parent  = "infra"
        }
      }
      disk = {
        name = "root"
        properties = {
          pool = "local"
          path = "/"
        }
      }
    }
  }
}

variable "lxd_storage" {
  description = "A map containing lxd storage config"
  type = object({
    name   = string
    driver = string
    config = map(any)
  })
  default = {
    name   = "infra"
    driver = "zfs"
    config = {
      "zfs.pool_name" = "zfs0"
    }
  }
}

variable "vault_root_ca" {
  description = "A map containing root ca parameters"
  type        = map(any)
  default = {
    type                 = "internal"
    common_name          = "Root CA"
    ttl                  = 315360000 // 10 years
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
    ttl                  = 157680000 // 5 years
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
    ttl                  = 63072000 // 2 years
    format               = "pem"
    private_key_format   = "der"
    key_type             = "rsa"
    key_bits             = 4096
    exclude_cn_from_sans = true
    ou                   = "Operations"
    organization         = "Internal Org"
  }
}
