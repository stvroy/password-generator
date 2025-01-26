provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "devops_key" {
  key_name   = "devops-key" # The name of the key pair in AWS
  public_key = file("~/Documents/test-keys/devops-key.pub") # Path to your local public key
}

resource "aws_instance" "web" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.devops_key.key_name

  tags = {
    Name = "devops-web"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF
}

resource "aws_security_group" "pass_sg" {
  name_prefix = "pass-sg-"

  ingress {
    from_port   = 80
    to_port     = 80
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