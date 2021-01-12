// Root PKI
resource "vault_pki_secret_backend" "root" {
  description               = "PKI for Root CA"
  path                      = "pki-root-ca"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend              = vault_pki_secret_backend.root.path
  type                 = "internal"
  common_name          = "Root CA"
  ttl                  = "315360000"
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "My OU"
  organization         = "My organization"
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
  type               = "internal"
  common_name        = "Intermediate CA"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = "4096"
  depends_on         = [vault_pki_secret_backend_root_cert.root]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend              = vault_pki_secret_backend.root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = "Intermediate CA"
  ttl                  = "315360000"
  exclude_cn_from_sans = true
  ou                   = "My OU"
  organization         = "My organization"
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
  type               = "internal"
  common_name        = "Infra CA"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = "4096"
  depends_on         = [vault_pki_secret_backend.intermediate]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "infra" {
  backend              = vault_pki_secret_backend.intermediate.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.infra.csr
  common_name          = "Infra CA"
  ttl                  = "315360000"
  exclude_cn_from_sans = true
  ou                   = "My OU"
  organization         = "My organization"
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.infra]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "infra" {
  backend     = vault_pki_secret_backend.infra.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.infra.certificate
}

resource "vault_pki_secret_backend_role" "infra" {
  backend = vault_pki_secret_backend.infra.path
  name    = "infra"
}
