# Terraform LXD - Infra

## Setup
```bash
export LXD_REMOTE=<lxd_name>
export LXD_ADDR=<lxd_addr>
export LXD_PORT=<lxd_port>
export LXD_PASSWORD=<lxd_pass>
export LXD_SCHEME=<http|https>
export VAULT_SKIP_VERIFY=1
export VAULT_ADDR=https://<vault_addr>:8200
export VAULT_TOKEN=<vault_token>
```

## Run
```bash
terraform init
terraform plan
terraform apply
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| lxd | n/a |
| vault | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain\_name | The name of the top level domain | `string` | `"internal"` | no |
| lxd\_network | A map containing lxd network config | `map(any)` | <pre>{<br>  "ipv4_address": "10.150.19.1/24",<br>  "ipv4_nat": true,<br>  "name": "infra"<br>}</pre> | no |
| lxd\_profile | A map containing lxd profile config | <pre>object({<br>    name    = string<br>    devices = map(any)<br>  })</pre> | <pre>{<br>  "devices": {<br>    "disk": {<br>      "name": "root",<br>      "properties": {<br>        "path": "/",<br>        "pool": "local"<br>      }<br>    },<br>    "nic": {<br>      "name": "eno1",<br>      "properties": {<br>        "nictype": "bridged",<br>        "parent": "infra"<br>      }<br>    }<br>  },<br>  "name": "infra"<br>}</pre> | no |
| vault\_infra\_ca | A map containing infra ca parameters | `map(any)` | <pre>{<br>  "common_name": "Infra CA",<br>  "exclude_cn_from_sans": true,<br>  "format": "pem",<br>  "key_bits": 4096,<br>  "key_type": "rsa",<br>  "organization": "Internal Org",<br>  "ou": "Operations",<br>  "private_key_format": "der",<br>  "ttl": 63072000,<br>  "type": "internal"<br>}</pre> | no |
| vault\_intermediate\_ca | A map containing intermedite ca parameters | `map(any)` | <pre>{<br>  "common_name": "Intermediate CA",<br>  "exclude_cn_from_sans": true,<br>  "format": "pem",<br>  "key_bits": 4096,<br>  "key_type": "rsa",<br>  "organization": "Internal Org",<br>  "ou": "Operations",<br>  "private_key_format": "der",<br>  "ttl": 157680000,<br>  "type": "internal"<br>}</pre> | no |
| vault\_root\_ca | A map containing root ca parameters | `map(any)` | <pre>{<br>  "common_name": "Root CA",<br>  "exclude_cn_from_sans": true,<br>  "format": "pem",<br>  "key_bits": 4096,<br>  "key_type": "rsa",<br>  "organization": "Internal Org",<br>  "ou": "Operations",<br>  "private_key_format": "der",<br>  "ttl": 315360000,<br>  "type": "internal"<br>}</pre> | no |

## Outputs

No output.

