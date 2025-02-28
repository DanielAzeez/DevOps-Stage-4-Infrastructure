provider "aws" {
  region = "eu-north-1"  # Change to your AWS region
}

resource "aws_instance" "app_server" {
  ami             = "ami-09a9858973b288bdd"  # Change to your preferred AMI
  instance_type   = "t2.micro"
  key_name        = "todoapp"  # Your SSH key pair
  security_groups = ["sg-07d28fc51f1ad7e13"]  # Use a list (square brackets)

  tags = {
    Name = "DevOps-Stage-4-Instance"
  }
}

# Fetch the existing Elastic IP
data "aws_eip" "existing_eip" {
  public_ip = "51.21.154.65"
}

# Associate the existing Elastic IP with the instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.app_server.id
  allocation_id = data.aws_eip.existing_eip.id
}

# Generate Ansible inventory file
resource "local_file" "inventory" {
  content  = <<EOT
[app_server]
${aws_instance.app_server.public_ip} ansible_ssh_user=ubuntu ansible_private_key_file=~/.ssh/todoapp.pem
EOT
  filename = "${path.module}/ansible/inventory.ini"
}

# Automatically trigger Ansible after Terraform completes
resource "null_resource" "ansible_provision" {
  depends_on = [aws_instance.app_server]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EC2 instance to be reachable..."
      while ! nc -z ${aws_instance.app_server.public_ip} 22; do sleep 5; done
      echo "Instance is up. Running Ansible playbook..."
      
      chmod 400 ~/.ssh/todoapp.pem  # Ensure key permissions
      which ansible-playbook || { echo "Ansible not installed! Exiting."; exit 1; }
      
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --private-key ~/.ssh/todoapp.pem
    EOT
  }
}
