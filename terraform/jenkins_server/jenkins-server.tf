data "aws_ami" "ubuntu" {
  owners = ["099720109477"]
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins-server" {
    ami = data.aws_ami.ubuntu.id 
    instance_type = var.instance_type 
    key_name = "jenkins_key"
    subnet_id = aws_subnet.jenkins-subnet.id 
    vpc_security_group_ids = [aws_default_security_group.jenkins-sg.id]
    availability_zone = var.avail_zone 
    associate_public_ip_address = true 
    user_data = file("../../utils/install-jenkins.sh")
    tags = {
        Name = "jenkins-server"
    }
}