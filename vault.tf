// Enable approle backend
resource "vault_auth_backend" "approle" {
  type = "approle"
}

// Create infra policy
data "vault_policy_document" "infra" {
  rule {
    description  = "Infra policy to allow read on pki-intermediate-ca"
    path         = "secret/pki-intermediate-ca/cert/ca"
    capabilities = ["read"]
  }
  rule {
    description  = "Infra policy to allow certificate creation"
    path         = "secret/pki-infra/issue/*"
    capabilities = ["read", "update"]
  }
  rule {
    description  = "Infra policy to allow all capabilities on secrets/infra"
    path         = "secret/infra/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
}

resource "vault_policy" "infra" {
  name   = "infra"
  policy = data.vault_policy_document.infra.hcl
}

resource "vault_approle_auth_backend_role" "infra" {
  backend        = vault_auth_backend.approle.path
  role_name      = "infra"
  token_policies = ["default", "infra"]
}

// Enable infra secrets mount
resource "vault_mount" "infra" {
  description = "Generic infrastructure secrets"
  path        = "infra"
  type        = "generic"
}
