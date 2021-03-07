module "earth" {
  source = "./modules/planet"

  providers = {
    aws = aws.earth
  }

  name                    = "earth"
  vpc_cidr                = var.earth_vpc_cidr
  instance_type           = var.instance_type
  network_interface_count = var.network_interface_count
  key_name                = var.key_name
  icmp_whitelist_cidrs    = [var.mars_vpc_cidr, var.venus_vpc_cidr]
  rdp_whitelist_cidrs     = [var.rdp_whitelist_cidr]
  nginx_whitelist_cidrs   = [var.mars_vpc_cidr, var.venus_vpc_cidr]

  tags = {
    Environment = var.environment
  }
}

module "mars" {
  source = "./modules/planet"

  providers = {
    aws = aws.mars
  }

  name                    = "mars"
  vpc_cidr                = var.mars_vpc_cidr
  instance_type           = var.instance_type
  network_interface_count = var.network_interface_count
  key_name                = var.key_name
  icmp_whitelist_cidrs    = [var.earth_vpc_cidr, var.venus_vpc_cidr]
  rdp_whitelist_cidrs     = [var.rdp_whitelist_cidr]
  nginx_whitelist_cidrs   = [var.earth_vpc_cidr, var.venus_vpc_cidr]

  tags = {
    Environment = var.environment
  }
}

module "venus" {
  source = "./modules/planet"

  providers = {
    aws = aws.venus
  }

  name                    = "venus"
  vpc_cidr                = var.venus_vpc_cidr
  instance_type           = var.instance_type
  network_interface_count = var.network_interface_count
  key_name                = var.key_name
  icmp_whitelist_cidrs    = [var.earth_vpc_cidr, var.mars_vpc_cidr]
  rdp_whitelist_cidrs     = [var.rdp_whitelist_cidr]
  nginx_whitelist_cidrs   = [var.earth_vpc_cidr, var.mars_vpc_cidr]

  tags = {
    Environment = var.environment
  }
}

module "earth-mars-peering" {
  source = "./modules/vpc-peering"

  providers = {
    aws.local = aws.earth
    aws.peer  = aws.mars
  }

  peer_region          = var.mars_region
  peer_vpc_id          = module.mars.vpc_id
  peer_vpc_cidr        = var.mars_vpc_cidr
  peer_route_table_ids = module.mars.vpc_public_route_table_ids

  local_vpc_id          = module.earth.vpc_id
  local_vpc_cidr        = var.earth_vpc_cidr
  local_route_table_ids = module.earth.vpc_public_route_table_ids
}

module "mars-venus-peering" {
  source = "./modules/vpc-peering"

  providers = {
    aws.local = aws.mars
    aws.peer  = aws.venus
  }

  peer_region          = var.venus_region
  peer_vpc_id          = module.venus.vpc_id
  peer_vpc_cidr        = var.venus_vpc_cidr
  peer_route_table_ids = module.venus.vpc_public_route_table_ids

  local_vpc_id          = module.mars.vpc_id
  local_vpc_cidr        = var.mars_vpc_cidr
  local_route_table_ids = module.mars.vpc_public_route_table_ids
}

module "venus-earth-peering" {
  source = "./modules/vpc-peering"

  providers = {
    aws.local = aws.venus
    aws.peer  = aws.earth
  }

  peer_vpc_id          = module.earth.vpc_id
  peer_region          = var.earth_region
  peer_vpc_cidr        = var.earth_vpc_cidr
  peer_route_table_ids = module.earth.vpc_public_route_table_ids


  local_vpc_id          = module.venus.vpc_id
  local_vpc_cidr        = var.venus_vpc_cidr
  local_route_table_ids = module.venus.vpc_public_route_table_ids
}
