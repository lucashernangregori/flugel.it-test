data "aws_vpc" "test" {
  provider = aws.region_master
  tags = {
    "Name" = "test"
  }
}

data "aws_subnet" "test_private" {
  provider = aws.region_master
  tags = {
    "Name" = "test_private",
    "Count" = "0"
  }
}

data "aws_subnet" "test_public_0" {
  provider = aws.region_master
  tags = {
    "Name" = "test_public",
    "Count" = "0"
  }
}

data "aws_subnet" "test_public_1" {
  provider = aws.region_master
  tags = {
    "Name" = "test_public",
    "Count" = "1"
  }
}


data "aws_instance" "traefik" {
  provider = aws.region_master
  instance_tags = {
    Name = "traefik"
  }
}