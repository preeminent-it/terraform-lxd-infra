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

  dynamic "lxd_remote" {
    for_each = var.lxd_remote
    content {
      name     = lxd_remote.key
      scheme   = lxd_remote.value.scheme
      address  = lxd_remote.value.address
      password = lxd_remote.value.password
      default  = lxd_remote.value.default
    }
  }
}

provider "vault" {
  //address = "https://${lxd_container.vault["vault1"].ipv4_address}:8200"
}
