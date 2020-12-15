provider "aws" {
  profile = var.profile
  region  = var.region_master
  alias   = "region_master"
}