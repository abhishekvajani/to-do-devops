provider "aws" {
  region = "us-west-2"
}

# Create IAM role for the Jenkins server
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policies to the IAM role (customize as needed)
resource "aws_iam_role_policy_attachment" "s3_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_full_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow access to Jenkins, Docker, and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow Jenkins access
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins agent port
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-070686bd03233cfa1" # Ubuntu 20.04 AMI ID (us-west-2)
  instance_type = "t3.medium"
  key_name      = "devops3" # Update with your key name

  tags = {
    Name = "Jenkins-Server"
  }

  # Use security group for allowing Jenkins, Docker, and SSH traffic
  security_groups = [aws_security_group.jenkins_sg.name]

  # Attach the IAM role to the EC2 instance
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name

}

# Create an instance profile for the Jenkins role
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins_instance_profile"
  role = aws_iam_role.jenkins_role.name
}