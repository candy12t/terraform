resource "aws_instance" "study_ubuntu_01_instance" {
  ami                    = "ami-0df99b3a8349462c6"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.study_private_01_subent.id
  vpc_security_group_ids = [aws_security_group.study_ec2_security_group.id]
}

resource "aws_instance" "study_ubuntu_02_instance" {
  ami                    = "ami-0df99b3a8349462c6"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.study_private_02_subent.id
  vpc_security_group_ids = [aws_security_group.study_ec2_security_group.id]
}

resource "aws_lb_target_group" "study_alb" {
  name     = "study-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.study_vpc.id
}

resource "aws_lb" "study_alb" {
  name               = "study-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.study_lb_security_group.id]
  subnets            = [aws_subnet.study_public_01_subent.id, aws_subnet.study_public_02_subent.id]
}

