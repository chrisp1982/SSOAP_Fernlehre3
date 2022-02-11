resource "aws_launch_configuration" "podtatohead-arms" {
  image_id = data.aws_ami.amazon-2.image_id
  instance_type = "t3.micro"
  user_data = base64encode(templatefile("${path.module}/templates/init.tpl", {
    container_image = "ghcr.io/fhb-codelabs/podtato-small-arms",
    podtato_version=var.podtato_version,
    left_version=var.left_arm_version,
    right_version=var.right_arm_version,
    VarDdApiKey = var.VarDdApiKey,
    VarDdImage = var.VarDdImage
  } ))

  security_groups = [aws_security_group.ingress-all-ssh.id, aws_security_group.ingress-all-http.id]
  name_prefix = "${var.podtato_name}-podtatohead-arms-"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "asg-podtatohead-arms" {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  desired_capacity   = var.desired_instances
  max_size           = var.max_instances
  min_size           = var.min_instances
  name = "${var.podtato_name}-arms-asg"

  launch_configuration = aws_launch_configuration.podtatohead-arms.name


  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.arms_elb.id
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
  tag {
    key                 = "Name"
    value               = "${var.podtato_name}-podtatohead-arms"
    propagate_at_launch = true
  }
}

resource "aws_elb" "arms_elb" {
  name = "${var.podtato_name}-arms-elb"
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  security_groups = [
    aws_security_group.elb_http_8080.id
  ]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/images/left-arm-01.svg"
  }

  listener {
    lb_port = 8080
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }

}
