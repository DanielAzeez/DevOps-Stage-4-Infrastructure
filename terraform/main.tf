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

# Fetch the existing Elastic IP (51.21.154.65)
data "aws_eip" "existing_eip" {
  public_ip = "51.21.154.65"
}

# Associate the existing Elastic IP with the new instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.app_server.id
  allocation_id = data.aws_eip.existing_eip.id
}

# Generate Ansible inventory file dynamically
resource "local_file" "inventory" {
  content  = <<EOT
[app_server]
${aws_instance.app_server.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/todoapp.pem
EOT
  filename = "${path.module}/ansible/inventory.ini"
}

# Trigger Ansible Playbook Execution
resource "null_resource" "ansible_provision" {
  depends_on = [aws_instance.app_server, local_file.inventory]

  provisioner "local-exec" {
    command = <<EOT
      chmod 600 ~/.ssh/todoapp.pem  # Ensure key has correct permissions
      ansible-playbook -i ${path.module}/ansible/inventory.ini ${path.module}/ansible/playbook.yml
    EOT
  }
}
