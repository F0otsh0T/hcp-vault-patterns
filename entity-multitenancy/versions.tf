# versions.tf

terraform {
  required_version = ">= 1.5.7"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.21.0"
    }
  }
}

provider "vault" {
  # Configuration options
  address = var.vault_addr
  # Only for DEV Environments
  skip_tls_verify = true
}





