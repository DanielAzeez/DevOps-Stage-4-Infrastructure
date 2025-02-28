# DevOps Stage 4 - Automated Infrastructure & Deployment

## Overview
This project automates the provisioning and configuration of infrastructure using **Terraform** and **Ansible**. With a **single command**, the entire infrastructure and application deployment process is executed.

## Features
- **Terraform** provisions an AWS EC2 instance and associates an Elastic IP.
- **Ansible** installs dependencies, deploys the application, and sets up SSL/TLS with Traefik.
- Fully **automated workflow** where Terraform triggers Ansible.

## Prerequisites
Ensure you have the following installed:
- **Terraform** (>= 1.0)
- **Ansible** (>= 2.9)
- **AWS CLI** configured with necessary permissions
- SSH key (`todoapp.pem`) with proper permissions:
  ```bash
  chmod 400 ~/.ssh/todoapp.pem
  ```

## Infrastructure Setup
Terraform provisions the following AWS resources:
1. An **EC2 instance** (Ubuntu) with a specified **Elastic IP**.
2. A **security group** allowing necessary ports.
3. An **Ansible inventory file** dynamically generated.
4. **Automatic Ansible execution** after provisioning.

## Deployment Instructions
### 1. Clone Repository
```bash
git clone https://github.com/DanielAzeez/DevOps-Stage-4-Infrastructure.git
cd DevOps-Stage-4-Infrastructure
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Apply Terraform Configuration
Run the following command to **provision infrastructure and deploy the application**:
```bash
terraform apply -auto-approve
```

### 4. Verify Deployment
Once Terraform completes:
- The EC2 instance will be provisioned.
- Ansible will install dependencies and deploy the application.
- The application should be accessible via the Elastic IP.

To manually check the Ansible execution:
```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

## File Structure
```
DevOps-Stage-4-Infrastructure/
│── terraform/
│   ├── main.tf  # Terraform configuration for EC2 and security groups
│   ├── variables.tf  # Define Terraform variables
│   ├── outputs.tf  # Capture Terraform outputs
│── ansible/
│   ├── inventory.ini  # Automatically generated inventory file
│   ├── playbook.yml  # Ansible playbook for configuration and deployment
│   ├── roles/
│       ├── dependencies/  # Installs Docker, Traefik, and other dependencies
│       ├── deployment/  # Deploys application using Docker Compose
└── README.md  # Project documentation
```

### Destroy Infrastructure
To delete all provisioned resources:
```bash
terraform destroy -auto-approve
```

## Conclusion
This setup ensures **fully automated infrastructure provisioning and application deployment** in a single step.

