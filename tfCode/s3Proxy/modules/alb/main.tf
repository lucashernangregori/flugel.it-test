terraform {
  required_version = ">= 0.14"
  backend "local" {
    path = "terraform.tfstate"
  }
}
