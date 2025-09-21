provider "aws" {
  region = "us-east-1"
}


data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

terraform {
  required_providers {
    env = {
      source = "e-breuninger/env" 
      version = "0.5.0"
    }
  }
}

data "env_variable" "ssh_key" {
  name = "SSH_PUBLIC_KEY"
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = data.env_variable.ssh_key.value
}

resource "aws_security_group" "app_sg" {
  name        = "rabbitmq-nginx-sg"
  description = "Allow HTTP, SSH & RabbitMQ"
  vpc_id      = data.aws_vpc.default.id

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #NGINX
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RabbitMQ Management UI
  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #RABBITMQ AMQP
  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rabbitmq-nginx-sg"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data_base64 = base64encode(templatefile("../user_data.sh", {
    docker_compose_content = file("../docker-compose.yml")
    nginx_conf_content     = file("../nginx.conf")
  }))

  tags = {
    Name = "rabbitmq-nginx-app"
  }
}
