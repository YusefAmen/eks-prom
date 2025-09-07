module "network" {
  source = "./10-network"

  project  = var.project
  vpc_cidr = "10.0.0.0/16" # TODO: keep or change if you need a different block
  az_count = 2             # TODO: keep 2 for free-tier learning; raise later if needed
}
module "eks" {
  source             = "./20-eks"
  project            = var.project
  cluster_version    = "1.29" # TODO: keep or change to what you want
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  vpc_id             = module.network.vpc_id
}
