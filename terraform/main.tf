provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "app_server" {
  ami                    = "ami-09a9858973b288bdd"
  instance_type          = "t3.micro"
  key_name               = "todoapp"
  vpc_security_group_ids = ["sg-07d28fc51f1ad7e13"]

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

# Generate Ansible inventory file in the correct folder
resource "local_file" "inventory" {
  content  = <<EOT
[app_server]
${aws_instance.app_server.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/danielazeez/todoapp.pem
EOT
  filename = "${path.module}/../ansible/inventory.ini"  # Adjusted path for inventory.ini
}

# Run Ansible automatically after Terraform completes
resource "null_resource" "ansible_provision" {
  depends_on = [aws_instance.app_server, local_file.inventory]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EC2 instance to be reachable..."
      until ssh -o StrictHostKeyChecking=no -i /home/danielazeez/todoapp.pem ubuntu@${aws_instance.app_server.public_ip} 'exit' 2>/dev/null; do
        sleep 5
      done

      echo "Instance is up. Running Ansible playbook..."
      
      chmod 400 /home/danielazeez/todoapp.pem  # Ensure key permissions
      which ansible-playbook || { echo "Ansible not installed! Exiting."; exit 1; }

      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory.ini ../ansible/playbook.yml --private-key /home/danielazeez/todoapp.pem
    EOT
  }
}
