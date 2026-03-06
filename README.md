# Build5Nines MyIP Terraform Module (Retrieve Local IP for PC running Terraform)

Stop hard-coding IP addresses in your firewall rules and security groups.
This Terraform module automatically detects the **public IPv4 address** of the
machine running Terraform, so you can dynamically lock down access to only your
current location — no manual lookups, no stale addresses.

What you get:

- **Zero manual steps:** No more visiting "what is my IP" websites — the module does it for you.
- **Always current:** Every `terraform apply` picks up your latest public IP, keeping firewall rules in sync with where you actually are.
- **Works everywhere:** Use with Azure NSGs, AWS Security Groups, GCP firewall rules, or any resource that accepts a CIDR block.
- **Customizable source:** Swap the lookup URL if you prefer a different provider or need to query an internal endpoint.

## Quick Start

```hcl
module "myip" {
  source  = "Build5Nines/myip/http"
}

output "my_public_ip" {
  value = module.myip.ip_address
}
```

Running `terraform apply` will output your current public IPv4 address:

```text
my_public_ip = "203.0.113.42"
```

## Usage Examples

### Azure — Restrict an NSG Rule to Your IP

```hcl
module "myip" {
  source  = "Build5Nines/myip/http"
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSHFromMyIP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${module.myip.ip_address}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}
```

### AWS — Lock Down a Security Group to Your IP

```hcl
module "myip" {
  source  = "Build5Nines/myip/http"
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${module.myip.ip_address}/32"]
  security_group_id = aws_security_group.main.id
}
```

### GCP — Restrict a Firewall Rule to Your IP

```hcl
module "myip" {
  source  = "Build5Nines/myip/http"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-from-myip"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${module.myip.ip_address}/32"]
}
```

### Custom URL — Use a Different IP Lookup Provider

If you prefer a different service or need to query an internal endpoint, override
the `url` variable:

```hcl
module "myip" {
  source  = "Build5Nines/myip/http"
  url     = "https://api.ipify.org"
}
```

Any URL that returns a plain-text IPv4 address will work.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `url` | The URL to query for the public IP address. Must return a plain-text IPv4 address. | `string` | `"https://ipv4.icanhazip.com"` | no |

> The default URL (`https://ipv4.icanhazip.com`) is hosted by Cloudflare and returns the caller's IPv4 address in plain text.

## Outputs

| Name | Description |
|------|-------------|
| `ip_address` | The public IPv4 address of the machine running Terraform. |

## How It Works

1. The module sends an HTTP GET request to the configured `url` (default: `https://ipv4.icanhazip.com`).
2. The response body — a plain-text IPv4 address — is trimmed of any trailing whitespace or newline characters.
3. The cleaned IP address is exposed via the `ip_address` output, ready to use in any resource attribute that accepts an IP or CIDR value.

Internally, the module uses the Terraform [`http` data source](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) and the built-in `chomp()` function.

## FAQ

**Q: Does this return an IPv6 address?**
No. The default URL (`https://ipv4.icanhazip.com`) is IPv4-only. If you need IPv6, you can set `url = "https://ipv6.icanhazip.com"`, but note that downstream resources must support IPv6 CIDR notation.

**Q: What happens if the lookup URL is unreachable?**
Terraform will fail during the plan/apply phase with an HTTP error from the `http` data source. Ensure the machine running Terraform has outbound internet access.

**Q: Can I use this in CI/CD pipelines?**
Yes. The module will return the public IP of whatever machine executes `terraform apply` — your laptop, a GitHub Actions runner, an Azure DevOps agent, etc.

**Q: How do I form a CIDR block from the output?**
Append `/32` for a single-host CIDR: `"${module.myip.ip_address}/32"`.

## Acknowledgments

This project is created and maintained by [Chris Pietschmann](https://pietschsoft.com), Microsoft MVP, HashiCorp Ambassador, and founder of [Build5Nines](https://build5nines.com).
