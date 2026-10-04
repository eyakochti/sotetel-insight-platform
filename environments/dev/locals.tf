locals {
  projet = "sotetel"
  env    = "dev"
  owner  = "eya"

  prefix = "${local.projet}-${local.env}"

  tags = {
    projet = local.projet
    env    = local.env
    owner  = local.owner
  }
}