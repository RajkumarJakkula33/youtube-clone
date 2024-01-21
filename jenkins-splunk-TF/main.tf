resource "aws_security_group" "Jenkins-splunk-sg" {
  name        = "Jenkinsplunk-Security Group"
  description = "Open 22,443,80,8080,9000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkinssplunk-sg"
  }
}


resource "aws_instance" "jenkin-sonar" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  key_name               = "jan5"
  vpc_security_group_ids = [aws_security_group.Jenkins-splunk-sg.id]
  user_data              = templatefile("./install_jenkins.sh", {})

  tags = {
    Name = "Jenkins-sonar"
  }
  root_block_device {
    volume_size = 30
  }
}

resource "aws_instance" "splunk" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  key_name               = "jan5"
  vpc_security_group_ids = [aws_security_group.Jenkins-splunk-sg.id]

  tags = {
    Name = "splunk"
  }
  root_block_device {
    volume_size = 30
  }
}