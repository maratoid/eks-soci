terraform {
  required_version = ">= 1.11.6"

  required_providers {
    multipass = {
      source  = "todoroff/multipass"
      version = "~> 1.7"
    }
  }
}

provider "multipass" {
  command_timeout = 600 
}