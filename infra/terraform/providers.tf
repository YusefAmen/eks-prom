terraform {
  required_version = ">= 1.5.0"
  required_providers {
    #aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    aws         = { source = "hashicorp/aws",        version = ">= 6.0.0, < 7.0.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.29" }
    helm       = { source = "hashicorp/helm", version = "~> 2.13" }
  }

  backend "s3" {
    bucket         = "tf-state-142021135755-eks-prom" # <-- DynamoDB bucket you created
    key            = "global/eks-prom.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-eks-prom"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::142021135755:role/terraform-deployer"
    session_name = "terraform-eks-prom"
  }
}

