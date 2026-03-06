// Unit tests for the root module using Terraform's built-in test framework.

test {
  # Enable parallel execution for independent runs. Individual runs may
  # still override this setting if necessary.
  parallel = true
}

run "returns_valid_ipv4" {
  command = apply

  # Verify the output is not empty
  assert {
    condition     = length(output.ip_address) > 0
    error_message = "ip_address output must not be empty"
  }

  # Verify the output matches a valid IPv4 pattern (1-3 digits . 1-3 digits . 1-3 digits . 1-3 digits)
  assert {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", output.ip_address))
    error_message = "ip_address output must be a valid IPv4 address, got: ${output.ip_address}"
  }

  # Verify there is no trailing whitespace or newline
  assert {
    condition     = output.ip_address == trimspace(output.ip_address)
    error_message = "ip_address output must not contain leading or trailing whitespace"
  }
}

