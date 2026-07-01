provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "public" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "public-vpc" 
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.public.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name =" subnet-1"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.public.id


  tags = {
    Name ="gateway"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.public.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "purna-sg-1" {
  vpc_id = aws_vpc.public.id
  name = "purna-sg"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress{
    from_port = 8888
    to_port = 8888
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol ="-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "devops" {
  type = set(string)
  default = ["ansible","jenkins","tomcat"]
}

resource "aws_instance" "project-2" {
  for_each = var.devops
  ami = "ami-0f8a61b66d1accaee"
  instance_type = "t3.micro"
  key_name = "pubg-key"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [ aws_security_group.purna-sg-1.id ]
associate_public_ip_address = true
 tags = {
    Name = each.value
 }
}