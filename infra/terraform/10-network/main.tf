data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  # Take the first N AZs in your region
  azs = slice(data.aws_availability_zones.this.names, 0, var.az_count)

  # Split /16 into /20s (16 + 4 new bits = /20)
  public_subnets = [
    for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i)
  ]

  # Keep private subnets far apart to avoid overlap with future growth
  private_subnets = [
    for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 8)
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  # Ensure public subnets auto-assign public IPs
  map_public_ip_on_launch = true

  enable_nat_gateway   = false # cost control
  single_nat_gateway   = false
  create_igw           = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Helpful tags for later when we add AWS Load Balancer Controller
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

