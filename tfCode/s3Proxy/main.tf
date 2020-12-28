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

module "bastion_host" {
  source = "./modules/bastionHost"

  providers = {
    aws = aws.region_master
  }

  subnet_id = aws_subnet.test_public[0].id
  vpc_id                         = aws_vpc.test.id
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

  vpc_id                         = aws_vpc.test.id
  allow_inbound_from_cidr_blocks = ["0.0.0.0/0"]
  http_listener_ports            = [80]
  subnet_ids = [
    aws_subnet.test_public[0].id,
    aws_subnet.test_public[1].id
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
  vpc_id            = aws_vpc.test.id

  lb_arn       = module.load_balancer.alb_arn
  instance_ids = aws_instance.traefik[*].id
}