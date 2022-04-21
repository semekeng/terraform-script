terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "v_cidr_blocks" {
  description = "cidr block & name tags for vpc & subnets"
  # default = "10.0.30.0/24"
  type = list(object({
    cidr_block = string
    name = string
  }))
}
variable "availability_zone" {}

resource "aws_vpc" "development-vpc" {
  cidr_block = var.v_cidr_blocks[0].cidr_block
  tags = {
    Name: var.v_cidr_blocks[0].name
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id     = aws_vpc.development-vpc.id
  cidr_block = var.v_cidr_blocks[1].cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = var.v_cidr_blocks[1].name
  }
}

data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dev-subnet-2" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = var.v_cidr_blocks[2].cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = var.v_cidr_blocks[2].name
  }
}

output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}

output "aws_subnet-id" {
  value = aws_subnet.dev-subnet-2.id
}

