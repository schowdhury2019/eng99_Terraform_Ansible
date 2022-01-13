variable "name" {
  default = "eng99_sunny_app"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/18"
}

variable "app_ami_id" {
  # app instance ami
  # default = "ami-04c57e7b204ee8c56"
  # Standard linux
  default = "ami-07d8796a2b0f8d29c"
}

variable "aws_key" {
  default = "eng99"
}

variable "vpc_id" {
  default = "eng99_sunny_terraform_vpc"
}

variable "controller_name" {
  default = "eng99_sunny_terraform_controller"
}

variable "app_name" {
  default = "eng99_sunny_terraform_app"
}

variable "db_name" {
  default = "eng99_sunny_terraform_db"
}

variable "aws_public_cidr" {
  default = "10.0.0.0/24"
}

variable "aws_instance_type" {
  default = "t2.micro"
}

variable "aws_private_cidr" {
  default = "10.0.1.0/24"
}

variable "internet" {
  default = "0.0.0.0/0"
}

variable "public_route_table" {
  default = "Public Route Table"
}

variable "private_route_table" {
  default = "Private Route Table"
}

variable "public_sg" {
  default = "allow_public_access"
}

variable "my_ip" {
  default = "82.11.184.106/32"
}
