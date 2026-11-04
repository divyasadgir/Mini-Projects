
provider "aws" {
  region = "ap-southeast-2"
}

data "aws_vpc" "student_vpc" {
  id = "vpc-091d394d4df676355"
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.student_vpc.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_security_group" "student_sg" {
  name        = "unit4-student-sg"
  description = "Security group for student web server"
  vpc_id      = data.aws_vpc.student_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "unit4-student-sg"
  }
}

resource "aws_instance" "student_server" {
  ami                         = "ami-06259b63260eddc13"
  instance_type               = "t3.micro"
key_name = "mini project 4-key"
  subnet_id                   = data.aws_subnets.default_subnets.ids[0]
  vpc_security_group_ids      = [aws_security_group.student_sg.id]
  associate_public_ip_address = true


  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo '<h1>Unit 4 Student Platform</h1><p>Nginx is running!</p>' > /var/www/html/index.html
  EOF

  user_data_replace_on_change = true

  tags = {
    Name = "unit4-student-server"
  }
}

output "public_ip" {
  value = aws_instance.student_server.public_ip
}

output "instance_id" {
  value = aws_instance.student_server.id
}

