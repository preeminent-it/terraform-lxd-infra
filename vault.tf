// Create the Vault Container
resource "lxd_container" "vault" {
  for_each  = toset(formatlist("vault%s", range(1, 1 + var.server_count.vault)))
  name      = each.value
  image     = "vault-ubuntu-focal"
  profiles  = ["infra"]
  ephemeral = false

  config = {
    "boot.autostart" = true
  }

  depends_on = [lxd_network.main, lxd_profile.main, lxd_storage_pool.main]
}

// Enable infra secrets mount
resource "vault_mount" "secrets_infra" {
  description = "Generic infrastructure secrets"
  type        = "generic"
  path        = "infra"
  depends_on  = [lxd_container.vault]

}

// Enable approle backend
resource "vault_auth_backend" "approle" {
  type       = "approle"
  depends_on = [lxd_container.vault]
}

// Create infra policy
data "vault_policy_document" "infra" {
  rule {
    description  = "Infra policy to allow read on pki-intermediate-ca"
    path         = "${vault_mount.pki_intermediate.path}/cert/ca"
    capabilities = ["read"]
  }
  rule {
    description  = "Infra policy to allow certificate creation"
    path         = "${vault_mount.pki_infra.path}/issue/*"
    capabilities = ["read", "update"]
  }
  rule {
    description  = "Infra policy to allow all capabilities on secrets/infra"
    path         = "${vault_mount.secrets_infra.path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
}

resource "vault_policy" "infra" {
  name       = "infra"
  policy     = data.vault_policy_document.infra.hcl
  depends_on = [lxd_container.vault]
}

resource "vault_approle_auth_backend_role" "infra" {
  backend        = vault_auth_backend.approle.path
  role_name      = "infra"
  token_policies = ["default", "infra"]
  depends_on     = [lxd_container.vault]
}
