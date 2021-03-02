resource "aws_security_group" "sgautoscaling" {
  name        = "autoscaling"
  description = "secutiry group do autoscaling"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Autoscaling"
  }
}

resource "aws_launch_configuration" "lcautoscaling" {
  name          = "autoscaling-launcher"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  security_groups = [aws_security_group.sgautoscaling.id]
  associate_public_ip_address = true

  user_data = "${file("ec2_setup.sh")}"
}

resource "aws_autoscaling_group" "autoscalingg" {
  name                      = "terraform-autoscaling"
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  launch_configuration      = aws_launch_configuration.lcautoscaling.name
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.tg.arn]
  
}

resource "aws_autoscaling_policy" "scaleup" {
  name                   = "scaleup"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscalingg.name
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scaledown" {
  name                   = "scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscalingg.name
  policy_type            = "SimpleScaling"
}

resource "aws_instance" "ec2privada" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_id       = aws_subnet.private_b.id
  availability_zone = "${var.region}d"

  tags = {
    Name = "ec2privada"
  }
}