// Random 32 byte id for consul encrypt_key
resource "random_id" "consul_encrypt_key" {
  byte_length = 32
}

// Store the consul encrypt_key to Vault
resource "vault_generic_secret" "example" {
  path      = "${vault_mount.secrets_infra.path}/consul"
  data_json = "{ \"encrypt_key\": \"${random_id.consul_encrypt_key.b64_std}\" }"
}

// Create the Consul Container
resource "lxd_container" "consul" {
  name      = "consul"
  image     = "consul-ubuntu-focal"
  profiles  = ["infra"]
  ephemeral = false

  config = {
    "boot.autostart"             = true
    "environment.VAULT_PKI_PATH" = vault_mount.pki_infra.path
    "environment.VAULT_PKI_ROLE" = vault_pki_secret_backend_role.infra.name
    "environment.VAULT_PKI_SANS" = "localhost, consul.service.dc1.consul"
  }

  depends_on = [lxd_network.main, lxd_profile.main, lxd_storage_pool.main]
}
