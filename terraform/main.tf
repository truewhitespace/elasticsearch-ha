provider "aws" {
  version = "~> 3.0"
}

variable "building_ip" {
  description = "Default allows all SSH agents. Set to restrict to specific IP"
  default     = "0.0.0.0/0"
}

variable "ami_id" {
  description = "AMI to test"
  default     = "ami-08995713cf5b30d87"
}

variable "key_pair" {
  description = "AWS Key Pair to access the instance"
}

data "aws_region" "current" {}

locals {
  target_az = "${data.aws_region.current.name}a"
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volume.id
  instance_id = aws_instance.elastic-search.id
}

resource "aws_instance" "elastic-search" {
  ami                         = var.ami_id
  availability_zone           = local.target_az
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  key_name = var.key_pair

  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
  tags = {
    Name = "ElasticSearch"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_ebs_volume" "volume" {
  availability_zone = local.target_az
  size              = 1
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.target_az

  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow Http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Http traffic from VPC"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outgoing http traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH traffic from controlled host set"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.building_ip]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.route-table.id
}

output "Instance-Ip" {
  value = aws_instance.elastic-search.public_ip
}
