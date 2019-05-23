terraform {
  backend "s3" {
    bucket = "terraform.grimoire"
    key    = "znc.tfstate"
    region = "ca-central-1"
  }
}

provider "aws" {
  version = "~> 2.11"

  region = "ca-central-1"
}

provider "template" {
  version = "~> 2.1.2"
}

