data "template_cloudinit_config" "loki" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    merge_type   = "dict(recurse_array)+list(append)"
    content = templatefile("templates/cloudinit/base.tmpl", {
      fqdn           = "loki.${var.domain_name}"
      vault_pki_path = vault_mount.pki_infra.path
      vault_pki_role = vault_pki_secret_backend_role.infra.name
      vault_pki_sans = "localhost, loki.service.dc1.consul"
    })
  }
}

// Create the Loki Container
resource "lxd_container" "loki" {
  name      = "loki"
  image     = "loki-ubuntu-focal"
  profiles  = ["infra"]
  ephemeral = false

  config = {
    "boot.autostart" = true
    "user.user-data" = data.template_cloudinit_config.loki.rendered
  }

  depends_on = [lxd_network.main, lxd_profile.main, lxd_storage_pool.main]
}
