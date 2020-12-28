terraform {
  required_version = ">= 0.14"
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region_master
  alias   = "region_master"
}

module "networking" {
  source = "./modules/networking"

  providers = {
    aws = aws.region_master
  }

  vpc_cidr = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
}

module "bastion_host" {
  source = "./modules/bastionHost"

  providers = {
    aws = aws.region_master
  }

  subnet_id =  module.networking.public_subnets[0]
  vpc_id                         = module.networking.vpc_id
  key_pair_name = aws_key_pair.lucas.key_name
  ami_id = data.aws_ami.ubuntu.id
  workstation_external_cidr = local.workstation_external_cidr
}

module "load_balancer" {
  source = "./modules/alb"

  providers = {
    aws = aws.region_master
  }

  name = "traefik-lb"

  vpc_id                         =  module.networking.vpc_id
  allow_inbound_from_cidr_blocks = ["0.0.0.0/0"]
  http_listener_ports            = [80]
  subnet_ids = [
    module.networking.public_subnets
  ]
  internal = false
}

module "alb_target_group" {
  source = "./modules/albTargetGroup"

  providers = {
    aws = aws.region_master
  }

  target_group_name = "traefik-tg"
  port              = 80
  vpc_id            =  module.networking.vpc_id

  lb_arn       = module.load_balancer.alb_arn
  instance_ids = aws_instance.traefik[*].id
}