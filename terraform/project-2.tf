 provider "aws" {
   region = "us-east-1"
 }

# Create a VPC
 resource "aws_vpc" "purna" {
   cidr_block = "10.0.0.0/16"
   enable_dns_hostnames = true
    tags = {
      Name = "purna-vpc"
    }

 }
 # Create a public subnet
 resource "aws_subnet" "public" {
   vpc_id            = aws_vpc.purna.id
   cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
     tags = {
        Name = "purna-public-subnet"
     }
    }

    # Create an internet gateway
 resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.purna.id
    tags = {
      Name = "purna-igw"
    }
 }
# Create a route table
 resource "aws_route_table" "public" {
   vpc_id = aws_vpc.purna.id

   route { 
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
   }
    tags = {
      Name = "purna-public-rt"
    }
 }
 
 
# Associate the route table with the public subnet
 resource "aws_route_table_association" "public" {
   subnet_id      = aws_subnet.public.id
   route_table_id = aws_route_table.public.id
 }

 resource "aws_security_group" "purna_sg" {
   vpc_id = aws_vpc.purna.id
   name        = "purna-sg"
   description = "Allow SSH and jenkins"
  
 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
 }
variable "devops" {
  description = "Name of the existing EC2 Key Pair to use for SSH access"
  type        = set(string)
  default = [ " jenkins",
  "maven",
  "ansible" ]
}

resource "aws_instance" "new_project" {
    for_each = var.devops
  ami           = "ami-020728ad6199d7fa0" # ubuntu 20.04 LTS
  instance_type = "t3.micro"
  key_name      = "pubg-key"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids =  [aws_security_group.purna_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = each.value
  }
}