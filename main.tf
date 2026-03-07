# #######################################################
# Build5Nines MyIP Terraform Module
# Retrieve Local IP for PC running Terraform
#
# Source:
# https://github.com/Build5Nines/terraform-http-myip
#
# Author: Chris Pietschmann
# Copyright (c) 2026 Build5Nine LLC (https://build5nines.com)
# #######################################################

terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = ">= 2.2.0"
    }
  }
}

variable "url" {
  description = "The URL to query for the public IP address. Defaults to https://ipv4.icanhazip.com (hosted by Cloudflare), which returns the caller's IPv4 address in plain text."
  default     = "https://ipv4.icanhazip.com"
}

variable "request_headers" {
  description = "The HTTP Headers to use for the HTTP GET request. Defaults to Accept: text/plain."
  type        = map(any)

  default = {
    Accept = "text/plain"
  }
}

data "http" "url" {
  url = var.url

  request_headers = var.request_headers
}

output "ip_address" {
  description = "The public address of the machine running Terraform."
  value       = chomp(data.http.url.response_body)
}