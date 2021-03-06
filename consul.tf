// Random 32 byte id for consul encrypt_key
resource "random_id" "consul_encrypt_key" {
  byte_length = 32
}

// Store the consul encrypt_key to Vault
resource "vault_generic_secret" "example" {
  path      = "${vault_mount.secrets_infra.path}/consul"
  data_json = "{ \"encrypt_key\": \"${random_id.consul_encrypt_key.b64_std}\" }"
}

data "template_cloudinit_config" "consul" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    merge_type   = "dict(recurse_array)+list(append)"
    content = templatefile("templates/cloudinit/base.tmpl", {
      fqdn           = "consul.${var.domain_name}"
      vault_pki_path = vault_mount.pki_infra.path
      vault_pki_role = vault_pki_secret_backend_role.infra.name
      vault_pki_sans = "localhost, consul.service.dc1.consul"
    })
  }

  part {
    content_type = "text/cloud-config"
    merge_type   = "dict(recurse_array)+list(append)"
    content = templatefile("templates/cloudinit/consul.tmpl", {
    })
  }
}

// Create the Consul Container
resource "lxd_container" "consul" {
  for_each  = toset(formatlist("consul%s", range(1, 1 + var.server_count.consul)))
  name      = each.value
  image     = "consul-ubuntu-focal"
  profiles  = ["infra"]
  ephemeral = false

  config = {
    "boot.autostart" = true
    "user.user-data" = data.template_cloudinit_config.consul.rendered
  }

  depends_on = [lxd_network.main, lxd_profile.main, lxd_storage_pool.main]
}
