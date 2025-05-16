# A generic, reusable, standalone module for deploying an ASG that can do a 
# zero-downtime, rolling deployment.
locals {
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

resource "aws_launch_template" "example" {
  name_prefix            = "${var.cluster_name}-lt-"
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  # Render the User Data script as a template
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  }))

  # Required when using a launch configuration with an auto scaling group 
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  # Explicitly depend on the launch template's name so each time it's replaced, this ASG is also replaced
  name = "${var.cluster_name}-${aws_launch_template.example.name}"
  
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnet_ids # data.aws_subnets.default.ids

  target_group_arns = var.target_group_arns # [aws_lb_target_group.asg.arn]
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  # Wait for at least this many instances to pass health checks before considering the ASG deployment complete
  min_elb_capacity = var.min_size

  # When replacing this ASG, create the replacement first, and only delete the original after
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = {
      for key, value in var.custom_tags :
      key => upper(value)
      if key != "Name"
    }

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count                  = var.enable_autoscaling ? 1 : 0
  scheduled_action_name  = "${var.cluster_name}-scale-out-during-business-hours"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 2
  recurrence             = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                  = var.enable_autoscaling ? 1 : 0
  scheduled_action_name  = "${var.cluster_name}-scale-in-at-night"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  recurrence             = "0 12 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
}