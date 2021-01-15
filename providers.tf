terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
    }
  }
}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true
}

provider "vault" {
  address = "https://${lxd_container.vault.ipv4_address}:8200"
}
