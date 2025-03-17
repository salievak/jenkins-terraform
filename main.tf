provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "jterraform-ksalieva"  
    key    = "terraform.tfstate"   
    region = "us-east-1"                   
  }
}

#VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "jenkins-vpc"
  }
}

#Public

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

#Private

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "private-subnet-${count.index}"
  }
}

#IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "jenkins-igw"
  }
}

#Route table public

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#NAT and route table private

resource "aws_eip" "nat" {
  count  = 3
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = 3
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "nat-gateway-${count.index}"
  }
}

resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "private-route-table-${count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#Create EC2

#Security Group

resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins"
  vpc_id      = aws_vpc.main.id

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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# Key SSH

resource "tls_private_key" "jt_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "jt_key_pair" {
  key_name   = "jt-key-pair"
  public_key = tls_private_key.jt_key.public_key_openssh
}

# Save the private key to a local file
resource "local_file" "jt_private_key" {
  content  = tls_private_key.jt_key.private_key_pem
  filename = "${path.module}/ssh_keys/jt-private-key.pem"
  # Ensure proper file permissions for private key
  file_permission = "0600"
}

output "jt_ssh_command" {
  value = "ssh -i ${path.module}/ssh_keys/jt-private-key.pem ubuntu@${aws_eip.jenkins.public_ip}"
  description = "Command to SSH into the JT instance"
}

#EC2

resource "aws_instance" "jenkins" {
  ami             = var.ami  # Ubuntu 22.04
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public[0].id
  security_groups = [aws_security_group.jenkins.id]
  key_name        = aws_key_pair.jt_key_pair.key_name

  tags = {
    Name = "jenkins-instance"
  }

  #script install Jenkins and nginx

user_data = file("user_data.sh") # Script install jenkins, nginx and certbot

}

#Elastic IP

resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"
}

# DNS-zone

resource "aws_route53_zone" "main" {
  name = var.domain_name
}

# Create DNS A

resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.sub_domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.jenkins.public_ip]
}

#Password Admin

resource "random_password" "jenkins_admin" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "jenkins_admin" {
  name = "jenkins-admin-password-salik17"
}

resource "aws_secretsmanager_secret_version" "jenkins_admin" {
  secret_id     = aws_secretsmanager_secret.jenkins_admin.id
  secret_string = random_password.jenkins_admin.result
}
