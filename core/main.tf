terraform {
  required_providers {
    hcp = {
      source = "hashicorp/hcp"
      version = "0.69.0"
    }
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


variable "region" {
  default = "eu-west-1"
}

variable "regions" {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "boundary_admin_user" {
  default = "admin"
}

provider "hcp" {
  # Configuration options
}

provider "aws" {
  region = var.region
}