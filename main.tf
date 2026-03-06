variable "url" {
    description = "The URL to query for the public IP address. Defaults to https://ipv4.icanhazip.com (hosted by Cloudflare), which returns the caller's IPv4 address in plain text."
    default = "https://ipv4.icanhazip.com"
}

data "http" "url" {
    url = var.url
}

output "ip_address" {
    description = "The public address of the machine running Terraform."
    value = chomp(data.http.url.body)
}