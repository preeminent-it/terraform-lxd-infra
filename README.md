# Terraform LXD - Infra

## Setup
```bash
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
| vault | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain\_name | The name of the top level domain | `string` | `"internal"` | no |
| vault\_infra\_ca | A map containing infra ca parameters | `map(any)` | <pre>{<br>  "common_name": "Infra CA",<br>  "exclude_cn_from_sans": true,<br>  "format": "pem",<br>  "key_bits": 4096,<br>  "key_type": "rsa",<br>  "organization": "Internal Org",<br>  "ou": "Operations",<br>  "private_key_format": "der",<br>  "ttl": "730d",<br>  "type": "internal"<br>}</pre> | no |
| vault\_intermediate\_ca | A map containing intermedite ca parameters | `map(any)` | <pre>{<br>  "common_name": "Intermediate CA",<br>  "exclude_cn_from_sans": true,<br>  "format": "pem",<br>  "key_bits": 4096,<br>  "key_type": "rsa",<br>  "organization": "Internal Org",<br>  "ou": "Operations",<br>  "private_key_format": "der",<br>  "ttl": "1825d",<br>  "type": "internal"<br>}</pre> | no |
| vault\_root\_ca | A map containing root ca parameters | `map(any)` | <pre>{<br>  "common_name": "Root CA",<br>  "exclude_cn_from_sans": true,<br>  "format": "pem",<br>  "key_bits": 4096,<br>  "key_type": "rsa",<br>  "organization": "Internal Org",<br>  "ou": "Operations",<br>  "private_key_format": "der",<br>  "ttl": "3650d",<br>  "type": "internal"<br>}</pre> | no |

## Outputs

No output.

