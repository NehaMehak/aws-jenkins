# Create Network and EC2 instance

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "VPC"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}


# Create a Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Public RT"
  }
}

# Associate the Public Route Table to the Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

# Create a Route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create AWS Security Group
resource "aws_security_group" "aws_sec_grp" {
  name        = "aws_sec_grp"
  description = "AWS Security Group"
  vpc_id      = aws_vpc.vpc.id

  // To Allow SSH Transport
  ingress {
    from_port = var.ssh_default_port
    protocol = "tcp"
    to_port = var.ssh_default_port
    cidr_blocks = ["0.0.0.0/0"]
  }

 // To Allow Port 80 Transport
  ingress {
    from_port = var.jenkins_default_port
    protocol = "tcp"
    to_port = var.jenkins_default_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group"
  }
}

# Create SSH key

#resource "tls_private_key" "key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# Generate a Private Key and encode it as PEM.
resource "aws_key_pair" "key_pair" {
  key_name   = "key"
  public_key = var.ssh_public_key

#  provisioner "local-exec" {
#    command = "echo '${tls_private_key.key.private_key_pem}' > ./key.pem"
#  }
}

# Create an AWS Ubuntu Instance
resource "aws_instance" "node" {
  instance_type          = "t2.micro" # free instance
  #ami                    = "ami-052efd3df9dad4825"
  ami                    = "ami-0070c5311b7677678"
  key_name               = aws_key_pair.key_pair.id
  vpc_security_group_ids = [aws_security_group.aws_sec_grp.id]
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "TF Generated EC2 Instance"
  }

  user_data = file("${path.root}/scripts/userdata.tpl")

  root_block_device {
    volume_size = 10
  }
}