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

variable v_vpc_cidr_block {}
variable v_subnet_cidr_block {}
variable availability_zone {}
variable env_prefix {}
variable my_ip_for_ssh {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.v_vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.v_subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

resource "aws_security_group" "myapp-sg" {
  Name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {       # incomming traffic
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = [var.my_ip_for_ssh]
  }
  ingress {       # incomming traffic
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_block = ["0.0.0.0/0"]
  }

  egress {        # Outgoing traffic
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_block = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name: "${var.env_prefix}-sg"
  }
}