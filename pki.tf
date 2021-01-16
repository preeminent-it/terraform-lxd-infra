// Root PKI
resource "vault_mount" "pki_root" {
  description               = "PKI for Root CA"
  type                      = "pki"
  path                      = "pki-root-ca"
  default_lease_ttl_seconds = var.vault_root_ca.ttl
  max_lease_ttl_seconds     = var.vault_root_ca.ttl
  depends_on                = [lxd_container.vault]
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend              = vault_mount.pki_root.path
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
  depends_on           = [vault_mount.pki_root]
}

resource "vault_pki_secret_backend_config_urls" "root" {
  backend                 = vault_mount.pki_root.path
  issuing_certificates    = ["https://vault.${var.domain_name}:8200/v1/${vault_mount.pki_root.path}/ca"]
  crl_distribution_points = ["https://vault.${var.domain_name}:8200/v1/${vault_mount.pki_root.path}/crl"]
  depends_on              = [vault_pki_secret_backend_root_cert.root]
}

resource "vault_pki_secret_backend_crl_config" "root" {
  backend    = vault_mount.pki_root.path
  disable    = true
  expiry     = "72h"
  depends_on = [vault_pki_secret_backend_root_cert.root, vault_pki_secret_backend_config_urls.root]
}

// Intermediate PKI
resource "vault_mount" "pki_intermediate" {
  description               = "PKI for Intermediate CA"
  type                      = "pki"
  path                      = "pki-intermediate-ca"
  default_lease_ttl_seconds = var.vault_intermediate_ca.ttl
  max_lease_ttl_seconds     = var.vault_intermediate_ca.ttl
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend            = vault_mount.pki_intermediate.path
  type               = var.vault_intermediate_ca.type
  common_name        = var.vault_intermediate_ca.common_name
  format             = var.vault_intermediate_ca.format
  private_key_format = var.vault_intermediate_ca.private_key_format
  key_type           = var.vault_intermediate_ca.key_type
  key_bits           = var.vault_intermediate_ca.key_bits
  depends_on         = [vault_pki_secret_backend_root_cert.root]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend              = vault_mount.pki_root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = var.vault_intermediate_ca.common_name
  ttl                  = var.vault_intermediate_ca.ttl
  exclude_cn_from_sans = var.vault_intermediate_ca.exclude_cn_from_sans
  ou                   = var.vault_intermediate_ca.ou
  organization         = var.vault_intermediate_ca.organization
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.intermediate]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
  depends_on  = [vault_pki_secret_backend_root_sign_intermediate.intermediate]
}

resource "vault_pki_secret_backend_config_urls" "intermediate" {
  backend                 = vault_mount.pki_intermediate.path
  issuing_certificates    = ["https://vault.${var.domain_name}:8200/v1/${vault_mount.pki_intermediate.path}/ca"]
  crl_distribution_points = ["https://vault.${var.domain_name}:8200/v1/${vault_mount.pki_intermediate.path}/crl"]
  depends_on              = [vault_pki_secret_backend_intermediate_set_signed.intermediate]
}

resource "vault_pki_secret_backend_crl_config" "intermediate" {
  backend    = vault_mount.pki_intermediate.path
  disable    = true
  expiry     = "72h"
  depends_on = [vault_pki_secret_backend_intermediate_set_signed.intermediate, vault_pki_secret_backend_config_urls.intermediate]
}

// Generic Infra PKI
resource "vault_mount" "pki_infra" {
  description               = "PKI for generic infrastructure"
  type                      = "pki"
  path                      = "pki-infra"
  default_lease_ttl_seconds = var.vault_infra_ca.ttl
  max_lease_ttl_seconds     = var.vault_infra_ca.ttl
}

resource "vault_pki_secret_backend_intermediate_cert_request" "infra" {
  backend            = vault_mount.pki_infra.path
  type               = var.vault_infra_ca.type
  common_name        = var.vault_infra_ca.common_name
  format             = var.vault_infra_ca.format
  private_key_format = var.vault_infra_ca.private_key_format
  key_type           = var.vault_infra_ca.key_type
  key_bits           = var.vault_infra_ca.key_bits
  depends_on         = [vault_mount.pki_intermediate]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "infra" {
  backend              = vault_mount.pki_intermediate.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.infra.csr
  common_name          = var.vault_infra_ca.common_name
  ttl                  = var.vault_infra_ca.ttl
  exclude_cn_from_sans = var.vault_infra_ca.exclude_cn_from_sans
  ou                   = var.vault_infra_ca.ou
  organization         = var.vault_infra_ca.organization
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.infra]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "infra" {
  backend     = vault_mount.pki_infra.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.infra.certificate
}

resource "vault_pki_secret_backend_config_urls" "infra" {
  backend                 = vault_mount.pki_infra.path
  issuing_certificates    = ["https://vault.${var.domain_name}:8200/v1/${vault_mount.pki_infra.path}/ca"]
  crl_distribution_points = ["https://vault.${var.domain_name}:8200/v1/${vault_mount.pki_infra.path}/crl"]
  depends_on              = [vault_pki_secret_backend_intermediate_set_signed.infra]
}

resource "vault_pki_secret_backend_crl_config" "infra" {
  backend    = vault_mount.pki_infra.path
  disable    = true
  expiry     = "72h"
  depends_on = [vault_pki_secret_backend_intermediate_set_signed.infra, vault_pki_secret_backend_config_urls.infra]
}

resource "vault_pki_secret_backend_role" "infra" {
  backend           = vault_mount.pki_infra.path
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
