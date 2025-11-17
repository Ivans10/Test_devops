provider "aws" {
  region = "eu-north-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
data "aws_vpc" "infrastructure_vpc" {
  id = "vpc-xxxxxxxx"
}

data "aws_subnet" "first_subnet" {
  id = "subnet-xxxxxxx"
}
data "aws_subnet" "second_subnet" {
  id = "subnet-xxxxxxxx"
}

resource "aws_db_subnet_group" "database_subnet" {
  name       = "mydb-subnet-group"
  subnet_ids = [data.aws_subnet.first_subnet.id, data.aws_subnet.second_subnet.id]
}