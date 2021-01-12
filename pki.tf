// Root PKI
resource "vault_pki_secret_backend" "root" {
  description               = "PKI for Root CA"
  path                      = "pki-root-ca"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend              = vault_pki_secret_backend.root.path
  type                 = var.vault_root_ca.type
  common_name          = var.vault_root_ca.common_name
  ttl                  = var.vault_root_ca.ttl
  format               = var.vault_root_ca.format
  private_key_format   = var.vault_root_ca.private_key_format
  key_type             = var.vault_root_ca.key_type
  key_bits             = var.vault_root_ca.key_bits
  exclude_cn_from_sans = var.vault_root_ca.exclude_cn_from_sans
  ou                   = var.vault_root_ca.ou
  organization         = var.vault_root_ca.organization
  depends_on           = [vault_pki_secret_backend.root]
}

// Intermediate PKI
resource "vault_pki_secret_backend" "intermediate" {
  description               = "PKI for Intermediate CA"
  path                      = "pki-intermediate-ca"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend            = vault_pki_secret_backend.intermediate.path
  type               = var.vault_intermediate_ca.type
  common_name        = var.vault_intermediate_ca.common_name
  format             = var.vault_intermediate_ca.format
  private_key_format = var.vault_intermediate_ca.private_key_format
  key_type           = var.vault_intermediate_ca.key_type
  key_bits           = var.vault_intermediate_ca.key_bits
  depends_on         = [vault_pki_secret_backend_root_cert.root]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend              = vault_pki_secret_backend.root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = var.vault_intermediate_ca.common_name
  ttl                  = var.vault_intermediate_ca.ttl
  exclude_cn_from_sans = var.vault_intermediate_ca.exclude_cn_from_sans
  ou                   = var.vault_intermediate_ca.ou
  organization         = var.vault_intermediate_ca.organization
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.intermediate]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_pki_secret_backend.intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

// Generic Infra PKI
resource "vault_pki_secret_backend" "infra" {
  description               = "PKI for generic infrastructure"
  path                      = "pki-infra"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_pki_secret_backend_intermediate_cert_request" "infra" {
  backend            = vault_pki_secret_backend.infra.path
  type               = var.vault_infra_ca.type
  common_name        = var.vault_infra_ca.common_name
  format             = var.vault_infra_ca.format
  private_key_format = var.vault_infra_ca.private_key_format
  key_type           = var.vault_infra_ca.key_type
  key_bits           = var.vault_infra_ca.key_bits
  depends_on         = [vault_pki_secret_backend.intermediate]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "infra" {
  backend              = vault_pki_secret_backend.intermediate.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.infra.csr
  common_name          = var.vault_infra_ca.common_name
  ttl                  = var.vault_infra_ca.ttl
  exclude_cn_from_sans = var.vault_infra_ca.exclude_cn_from_sans
  ou                   = var.vault_infra_ca.ou
  organization         = var.vault_infra_ca.organization
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.infra]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "infra" {
  backend     = vault_pki_secret_backend.infra.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.infra.certificate
}

resource "vault_pki_secret_backend_role" "infra" {
  backend           = vault_pki_secret_backend.infra.path
  name              = "infra"
  allow_localhost   = false
  allowed_domains   = [var.domain_name]
  allow_subdomains  = true
  allow_any_name    = true
  enforce_hostnames = true
  allow_ip_sans     = false
  server_flag       = true
  client_flag       = true
}
