resource "aws_vpc" "jenkins-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "jenkins-vpc"
  }
}

resource "aws_subnet" "jenkins-subnet" {
  vpc_id            = aws_vpc.jenkins-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "jenkins-subnet"
  }
}

resource "aws_internet_gateway" "jenkins-igw" {
  vpc_id = aws_vpc.jenkins-vpc.id
  tags = {
    Name = "jenkins-igw"
  }
}

resource "aws_default_route_table" "jenkins-rtb" {
  default_route_table_id = aws_vpc.jenkins-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins-igw.id
  }
  tags = {
    Name = "jenkins-rtb"
  }
}

resource "aws_default_security_group" "jenkins-sg" {
  vpc_id = aws_vpc.jenkins-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
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
    Name = "jenkins-sg"
  }
}