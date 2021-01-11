// Enable approle backend
resource "vault_auth_backend" "approle" {
  type = "approle"
}

// Enable infra secrets mount
resource "vault_mount" "infra" {
  description = "Generic infrastructure secrets"
  path        = "infra"
  type        = "generic"
}

// Create operations policy
data "vault_policy_document" "operations" {
  rule {
    description  = "Operations policy to allow all capabilities on secrets/infra"
    path         = "secret/infra/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
}

resource "vault_policy" "operations" {
  name   = "operations"
  policy = data.vault_policy_document.operations.hcl
}
