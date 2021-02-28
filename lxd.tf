resource "lxd_network" "main" {
  for_each = var.lxd_remote
  target   = each.key
  name     = var.lxd_network.name
}

resource "lxd_network" "cluster" {
  name = var.lxd_network.name

  config = {
    "ipv4.address" = var.lxd_network.ipv4_address
    "ipv4.nat"     = var.lxd_network.ipv4_nat
  }

  depends_on = [lxd_network.main]
}

resource "lxd_profile" "main" {
  name = var.lxd_profile.name

  dynamic "device" {
    for_each = var.lxd_profile.devices
    content {
      name       = device.value.name
      type       = device.key
      properties = device.value.properties
    }
  }
}

resource "lxd_storage_pool" "main" {
  for_each = var.lxd_remote
  target   = each.key
  name     = var.lxd_storage.name
  driver   = var.lxd_storage.driver
  config   = var.lxd_storage.config
}

resource "lxd_storage_pool" "cluster" {
  name       = var.lxd_storage.name
  driver     = var.lxd_storage.driver
  depends_on = [lxd_storage_pool.main]
}
