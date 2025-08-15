terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

#Configuração do provedor da AWS

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      owner = "Júlia"
      managed-by = "minicurso-terraform"
    }
  }
}
