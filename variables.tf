variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "ami" {
  description = "AMI for EC2 instance"
  type        = string
  default     = "ami-0e1bed4f06a3b463d"  # Ubuntu 22.04
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for EC2 instance"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route 53"
  type        = string
  default     = "ksalieva06.pp.ua"
}

variable "sub_domain_name" {
    description = "Subdomain name for Route 53"
    type        = string
    default     = "jenkins.ksalieva06.pp.ua"
}