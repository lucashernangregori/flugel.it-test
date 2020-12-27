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