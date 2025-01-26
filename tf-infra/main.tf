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
  security_groups = [aws_security_group.pass_sg.name]

  tags = {
    Name = "password-gen"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl stop nginx
    systemctl disable nginx

    # Install Docker from the official Docker repository
    sudo apt update
    sudo apt install curl apt-transport-https ca-certificates software-properties-common
    sudo apt install docker.io -y 

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
 EOF
}

# Allocate an Elastic IP
resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
}

# Output the Elastic IP address
output "instance_ip" {
  value = aws_eip.web_eip.public_ip
}

resource "aws_security_group" "pass_sg" {
  name_prefix = "pass-sg-"

  ingress {
    from_port   = 80
    to_port     = 80
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
   from_port   = 22
   to_port     = 22
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