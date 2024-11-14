# For us-east-1:

# Security Group

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["142.59.28.49/32"]  # Restricted SSH to my IP only
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"]  # EC2 Instance Connect IP range for us-east-1
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
  }

  tags = {
    Name = "AppSecurityGroup"
  }
}

# Launch Template for EC2 Instances for us-east-1

resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-06b21ccaeff8cd686"  # Amazon Linux AMI
  instance_type = var.instance_type  
  # Attach the IAM role to EC2 instances
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    security_groups = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y nginx amazon-cloudwatch-agent
              sudo systemctl start nginx
              sudo systemctl enable nginx

              # Configure the CloudWatch Agent
              sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF2'
              {
                "metrics": {
                  "append_dimensions": {
                    "AutoScalingGroupName": "AppASGInstance"
                  },
                  "metrics_collected": {
                    "mem": {
                      "measurement": [
                        "mem_used_percent"
                      ],
                      "metrics_collection_interval": 60
                    },
                    "disk": {
                      "measurement": [
                        "used_percent"
                      ],
                      "resources": [
                        "/"
                      ],
                      "metrics_collection_interval": 60
                    }
                  }
                }
              }
              EOF2

              # Start the CloudWatch Agent
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -m ec2
            EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AppInstance"
    }
  }
}

# Auto Scaling Group (ASG) for us-east-1

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 1
  min_size             = 1
  max_size             = 5
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] 
  target_group_arns    = [aws_lb_target_group.primary.arn]  # Attach to ALB Target Group

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 120
    }
  }

  health_check_grace_period = 300  # Grace period
  health_check_type         = "ELB"  # Change to ELB-based health check

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "AppASGInstance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policies

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1  # Adds 1 instance when triggered
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1  # Removes 1 instance when triggered
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# For us-west-2:

# Security Group

resource "aws_security_group" "west_app_sg" {
  provider    = aws.west
  name        = "west-app-sg"
  description = "Allow HTTP and SSH traffic in us-west-2"
  vpc_id      = aws_vpc.west_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["142.59.28.49/32"]  # Restrict SSH to your IP
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.237.140.160/29"]  # EC2 Instance Connect IP range for us-west-2
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "WestAppSecurityGroup"
  }
}

# Launch Template for EC2 Instances in us-west-2

resource "aws_launch_template" "secondary_app" {
  provider       = aws.west
  name_prefix    = "secondary-app-launch-template"
  image_id       = "ami-07c5ecd8498c59db5"  # Amazon Linux AMI
  instance_type  = var.instance_type

  # Attach the IAM role to EC2 instances
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    security_groups = [aws_security_group.west_app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y nginx amazon-cloudwatch-agent
              sudo systemctl start nginx
              sudo systemctl enable nginx

              # Configure the CloudWatch Agent
              sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF2'
              {
                "metrics": {
                  "append_dimensions": {
                    "AutoScalingGroupName": "SecondaryAppASGInstance"
                  },
                  "metrics_collected": {
                    "mem": {
                      "measurement": [
                        "mem_used_percent"
                      ],
                      "metrics_collection_interval": 60
                    },
                    "disk": {
                      "measurement": [
                        "used_percent"
                      ],
                      "resources": [
                        "/"
                      ],
                      "metrics_collection_interval": 60
                    }
                  }
                }
              }
              EOF2

              # Start the CloudWatch Agent
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -m ec2
            EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "SecondaryAppInstance"
    }
  }
}

# Auto Scaling Group (ASG) for us-west-2

resource "aws_autoscaling_group" "secondary_asg" {
  provider            = aws.west
  desired_capacity    = 1
  min_size            = 1
  max_size            = 5
  vpc_zone_identifier = [aws_subnet.west_public_subnet_1.id, aws_subnet.west_public_subnet_2.id] 
  target_group_arns   = [aws_lb_target_group.secondary.arn]  # Attach to ALB Target Group

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 120
    }
  }

  health_check_grace_period = 300  # Grace period
  health_check_type         = "ELB"  # Use ELB-based health check for ALB

  launch_template {
    id      = aws_launch_template.secondary_app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "SecondaryAppASGInstance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policies

resource "aws_autoscaling_policy" "west_scale_up" {
  provider               = aws.west
  name                   = "west-scale-up"
  scaling_adjustment     = 1  # Adds 1 instance when triggered
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.secondary_asg.name
}

resource "aws_autoscaling_policy" "west_scale_down" {
  provider               = aws.west
  name                   = "west-scale-down"
  scaling_adjustment     = -1  # Removes 1 instance when triggered
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.secondary_asg.name
}