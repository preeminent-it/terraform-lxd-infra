resource "vault_approle_auth_backend_role" "jenkins" {
  backend        = vault_auth_backend.approle.path
  role_name      = "jenkins"
  token_policies = ["default", "dev", "prod"]
}
