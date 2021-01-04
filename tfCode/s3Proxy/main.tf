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

module "s3_bucket" {
  source = "./modules/s3Bucket"

  providers = {
    aws = aws.region_master
  }

  bucket_name   = var.bucket_name
  s3_test_files = var.s3_test_files
  s3_iam_role   = var.s3_iam_role
}

module "networking" {
  source = "./modules/networking"

  providers = {
    aws = aws.region_master
  }

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  s3_endpoint                        = var.s3_endpoint
  flow_log_iam_role                  = var.flow_log_iam_role
  flow_log_iam_role_policy           = var.flow_log_iam_role_policy
  cloudwatch_vpc_flow_log_group_name = var.cloudwatch_vpc_flow_log_group_name
}

module "bastion_host" {
  source = "./modules/bastionHost"

  providers = {
    aws = aws.region_master
  }

  subnet_id                 = module.networking.public_subnets[0]
  vpc_id                    = module.networking.vpc_id
  key_pair_name             = aws_key_pair.lucas.key_name
  ami_id                    = data.aws_ami.ubuntu.id
  workstation_external_cidr = local.workstation_external_cidr
  instance_role_id          = aws_iam_instance_profile.traefik.id
}

module "load_balancer" {
  source = "./modules/alb"

  providers = {
    aws = aws.region_master
  }

  name = "traefik-lb"

  vpc_id                         = module.networking.vpc_id
  allow_inbound_from_cidr_blocks = ["0.0.0.0/0"]
  http_listener_ports            = [80]
  subnet_ids                     = module.networking.public_subnets
  internal                       = false
}

module "alb_target_group" {
  source = "./modules/albTargetGroup"

  providers = {
    aws = aws.region_master
  }

  target_group_name = "traefik-tg"
  port              = 80
  vpc_id            = module.networking.vpc_id

  lb_arn       = module.load_balancer.alb_arn
  instance_ids = aws_instance.traefik[*].id
}