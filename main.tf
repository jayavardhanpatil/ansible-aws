variable "aws_key_pair" {
  default = "~/aws/aws_keys/default-ec2.pem"
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 3.6.0"
}

resource "aws_default_vpc" "default" {

}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = aws_default_vpc.default.id
}

data "aws_ami" "aws_linux_2_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

data "aws_ami_ids" "aws_linux_2_latest_ids" {
  owners = ["amazon"]
}

resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "http_server_sg"
  }
}



resource "aws_instance" "http_servers" {
  ami                    = data.aws_ami.aws_linux_2_latest.id
  count                  = 3
  key_name               = "default-ec2"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_server_sg.id]
  subnet_id              = "subnet-04123f3a"
  //subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]

  //for_each  = data.aws_subnet_ids.default_subnets.ids
  //subnet_id = each.value

  //tags = {
    //name : "http_servers_${each.value}"
  //}
}