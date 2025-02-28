variable "aws_region" {
  default = "eu-north-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "todoapp"
}

variable "security_group_id" {
  default = "sg-07d28fc51f1ad7e13"  # Use your actual security group ID
}

variable "elastic_ip" {
  default = "51.21.154.65"
}
