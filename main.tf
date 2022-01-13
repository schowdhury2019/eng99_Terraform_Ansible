# Let Terraform know who is our cloud provider

# AWS plugins/dependancies are installed
provider "aws" {
  region = "eu-west-1"
}

# Main VPC
resource "aws_vpc" "Sunny_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Sunny_vpc"
  }
}

# Internet Gatway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Sunny_vpc.id
  tags = {
    Name : "SunnyVPC IG"
  }
}

# -------- Subnets ---------------

# Public Subnet
resource "aws_subnet" "Public" {
  vpc_id     = aws_vpc.Sunny_vpc.id
  cidr_block = var.aws_public_cidr
  tags = {
    Name = "Public Subnet"
  }
}

# Private Subnet
resource "aws_subnet" "Private" {
  vpc_id     = aws_vpc.Sunny_vpc.id
  cidr_block = var.aws_private_cidr
  tags = {
    Name = "Private Subnet"
  }
}

# -------- RT ---------------

# Public Routing Table
resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.Sunny_vpc.id
  route {
    cidr_block = var.internet
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.public_route_table
  }
}

# Private Routing Table
resource "aws_route_table" "Private_RT" {
  vpc_id = aws_vpc.Sunny_vpc.id
  route {
    cidr_block = var.internet
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.private_route_table
  }
}

# Associating Public Subnet to routing table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.Public_RT.id
}

# Associating Private Subnet to routing table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.Private.id
  route_table_id = aws_route_table.Private_RT.id
}

# -------- SG ---------------

# Security Group Public App
resource "aws_security_group" "public" {
  name        = var.public_sg
  description = var.public_sg
  vpc_id      = aws_vpc.Sunny_vpc.id
}

# Security group Private DB
resource "aws_security_group" "private" {
  name        = "db_sg"
  description = "db_sg"
  vpc_id      = aws_vpc.Sunny_vpc.id
}

# resource "aws_security_group_rule" "public_in" {
#   type              = "ingress"
#   protocol          = "-1"
#   from_port         = 3000
#   to_port           = 3000
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.public.id
# }

# -------- SG Rules ---------------

resource "aws_security_group_rule" "app_ssh" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "app_outbound" {
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [var.internet]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "db" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "0"
  to_port           = "27017"
  cidr_blocks       = [var.aws_public_cidr]
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "db_outbound" {
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [var.internet]
  security_group_id = aws_security_group.private.id
}

# -------- Instances ---------------

# Controller Instance
resource "aws_instance" "controller_instance" {
  ami                         = var.app_ami_id
  subnet_id                   = aws_subnet.Public.id
  instance_type               = var.aws_instance_type
  security_groups             = [aws_security_group.public.id]
  associate_public_ip_address = true
  tags = {
    Name = var.controller_name
  }
  key_name = var.aws_key
}


# App Instance
resource "aws_instance" "app_instance" {
  # AMI id for 18.04LTS
  ami                         = var.app_ami_id
  subnet_id                   = aws_subnet.Public.id
  instance_type               = var.aws_instance_type
  security_groups             = [aws_security_group.public.id]
  associate_public_ip_address = true
  tags = {
    Name = var.app_name
  }
  # Allows terraform to use eng99.pem to connect to instance
  # Looks in .ssh folder
  key_name = var.aws_key
}

# DB Instance
resource "aws_instance" "db_instance" {
  ami                         = var.app_ami_id
  subnet_id                   = aws_subnet.Private.id
  instance_type               = var.aws_instance_type
  security_groups             = [aws_security_group.private.id]
  associate_public_ip_address = true
  tags = {
    Name = var.db_name
  }
  key_name = var.aws_key
}

output "app_ip" {
  value = aws_instance.app_instance.public_ip
}

output "db_ip" {
  value = aws_instance.db_instance.public_ip
}

# [app]
#ec2-instance ansible_host=$(terraform output app_ip) ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/eng99.pem

#[db]
#ec2-instance ansible_host=$(terraform output db_ip) ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/eng99.pem





# terraform plan
# terraform apply
