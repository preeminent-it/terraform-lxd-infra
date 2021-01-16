output "main" {
  value = {
    lxd_container                                      = lxd_container.vault
    lxd_network                                        = lxd_network.main
    lxd_profile                                        = lxd_profile.main
    lxd_storage_pool                                   = lxd_storage_pool.main
    vault_approle_auth_backend_role                    = merge(vault_approle_auth_backend_role.infra, vault_approle_auth_backend_role.jenkins)
    vault_auth_backend                                 = vault_auth_backend.approle
    vault_mount                                        = merge(vault_mount.infra, vault_mount.intermediate, vault_mount.root, vault_mount.secrets_infra)
    vault_pki_secret_backend_intermediate_cert_request = merge(vault_pki_secret_backend_intermediate_cert_request.infra, vault_pki_secret_backend_intermediate_cert_request.intermediate)
    vault_pki_secret_backend_intermediate_set_signed   = merge(vault_pki_secret_backend_intermediate_set_signed.infra, vault_pki_secret_backend_intermediate_set_signed.intermediate)
    vault_pki_secret_backend_role                      = vault_pki_secret_backend_role.infra
    vault_pki_secret_backend_root_cert                 = vault_pki_secret_backend_root_cert.root
    vault_pki_secret_backend_root_sign_intermediate    = merge(vault_pki_secret_backend_root_sign_intermediate.infra, vault_pki_secret_backend_root_sign_intermediate.intermediate)

  }
}
