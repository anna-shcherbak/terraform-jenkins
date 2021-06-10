terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

# Creation of security aws_security_group

variable "ingressrules" {
  type    = list(number)
  default = [8080, 22]
}
#security group for Jenkins master
resource "aws_security_group" "security_group_jenkins_master" {
  name        = "Allow traffic"
  description = "Allow ssh and 8080 ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

#security group for Jenkins agent
resource "aws_security_group" "security_group_jenkins_agent" {
  name        = "Allow ssh traffic"
  description = "Allow ssh port inbound and everything outbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}



data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

# Creation of jenkins master
resource "aws_instance" "jenkins_master" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.security_group_jenkins_master.name]
  key_name        = "jenkins_instance"
  user_data       = file("install_jenkins_master.sh")

  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}

resource "aws_instance" "jenkins_agent {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.security_group_jenkins_agent.name]
  key_name        = "jenkins_agent_aws"
  user_data       = file("install_jenkins_agent.sh")
  tags = {
    "Name"      = "Jenkins_Agent"
    "Terraform" = "true"
  }
}
