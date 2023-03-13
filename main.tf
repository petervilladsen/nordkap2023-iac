resource "aws_vpc" "nordkap_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "nordkap_vpc"
  }
}

resource "aws_subnet" "nordkap_public_subnet" {
  vpc_id                  = aws_vpc.nordkap_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "nordkap-public"
  }
}

resource "aws_internet_gateway" "nordkap_igw" {
  vpc_id = aws_vpc.nordkap_vpc.id

  tags = {
    Name = "nordkap-igw"
  }
}

resource "aws_route_table" "nordkap_public_rt" {
  vpc_id = aws_vpc.nordkap_vpc.id

  tags = {
    Name = "nordkap_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.nordkap_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nordkap_igw.id
}

resource "aws_route_table_association" "nordkap_public_assoc" {
  subnet_id      = aws_subnet.nordkap_public_subnet.id
  route_table_id = aws_route_table.nordkap_public_rt.id
}

resource "aws_security_group" "nordkap_sg" {
  name        = "nordkap_sg"
  description = "Nordkap security group"
  vpc_id      = aws_vpc.nordkap_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["80.209.74.115/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

/* resource "aws_key_pair" "nordkap_auth" {
  key_name   = "nordkap_key"
  public_key = file("./PeterTest.pem")
} */

resource "aws_instance" "nordkap-be" {
  instance_type          = "t2.micro"
  ami                    = "ami-06d94a781b544c133"
#  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [aws_security_group.nordkap_sg.id]
  subnet_id              = aws_subnet.nordkap_public_subnet.id
  key_name               = var.key_name
  #user_data              = "${file("userdata.sh")}"
  root_block_device {
    volume_size = 20
  }
  tags = {
    Name = "nordkap-node"
  }
}