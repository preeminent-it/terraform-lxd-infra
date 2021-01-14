resource "lxd_network" "main" {
  name = var.lxd_network.name

  config = {
    "ipv4.address" = var.lxd_network.ipv4_address
    "ipv4.nat"     = var.lxd_network.ipv4_nat
  }
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
