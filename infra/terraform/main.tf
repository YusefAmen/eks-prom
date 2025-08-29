module "network" {
  source = "./10-network"

  project  = var.project
  vpc_cidr = "10.0.0.0/16" # TODO: keep or change if you need a different block
  az_count = 2             # TODO: keep 2 for free-tier learning; raise later if needed
}

