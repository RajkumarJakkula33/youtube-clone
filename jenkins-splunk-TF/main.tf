# Create an IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-instance-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# Create EC2 Instance Profile

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = "${aws_iam_role.ec2_role.name}"
}

# Attach an inline policy to the IAM role (replace with your desired policy)
resource "aws_iam_role_policy" "ec2_role_policy" {
  name   = "ec2-instance-policy"
  role   = "${aws_iam_role.ec2_role.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Create an SG role for EC2
resource "aws_security_group" "Jenkins-splunk-sg" {
  name        = "Jenkinsplunk-Security Group"
  description = "Open 22,443,80,8080,9000"

# Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 8000] : {
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

# Create an Splunk and Jenkin-sonar Instance

resource "aws_instance" "jenkin-sonar" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.large"
  key_name               = "jan5"
  iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
  vpc_security_group_ids = [aws_security_group.Jenkins-splunk-sg.id]
  user_data              = file("install_jenkins.sh")

  tags = {
    Name = "Jenkins-sonar"
  }
  root_block_device {
    volume_size = 30
  }
}

resource "aws_instance" "splunk" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.medium"
  key_name               = "jan5"
  iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
  vpc_security_group_ids = [aws_security_group.Jenkins-splunk-sg.id]
  tags = {
    Name = "splunk"
  }
  root_block_device {
    volume_size = 30
  }
}
