# Preparing infrastructure on AWS cloud provider for Jenkins installation using Terraform

# Preparation:
- registered account in AWS
- installing the AWS CLI and setting up a profile
- install Terraform on your device
- a registered domain to set up Route 53 and

# Files that describe the creation and configuration of the infrastructure:
- main.tf - Description of the installation and configuration of the entire infrastructure
- outputs.tf - Output values
- variables.tf - Input variable
- terraform.tfvars - Variable values
- user_data.sh - A script to install Jenkins and Nginx
