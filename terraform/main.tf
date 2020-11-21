provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volume.id
  instance_id = aws_instance.elastic-search.id
}

resource "aws_instance" "elastic-search" {
  ami               = "ami-08995713cf5b30d87"
  availability_zone = "us-east-1a"
  instance_type     = "t3.medium"
  subnet_id = aws_subnet.main.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.allow_http.id]
  tags = {
    Name = "ElasticSearch"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_ebs_volume" "volume" {
  availability_zone = "us-east-1a"
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
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
