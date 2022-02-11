resource "aws_launch_configuration" "podtatohead-hats" {
  image_id = data.aws_ami.amazon-2.image_id
  instance_type = "t3.micro"

  user_data = base64encode(templatefile("${path.module}/templates/init_hats.tpl", 
  { container_image = "ghcr.io/fhb-codelabs/podtato-small-hats", 
  podtato_version=var.podtato_version, version=var.hats_version,
    VarDdApiKey = var.VarDdApiKey,
    VarDdImage = var.VarDdImage
  } ))

  security_groups = [aws_security_group.ingress-all-ssh.id, aws_security_group.ingress-all-http.id]
  name_prefix = "${var.podtato_name}-podtatohead-hats-"

  lifecycle {
    create_before_destroy = true
  }
}

################################################################ Autoscaling group for hats
resource "aws_autoscaling_group" "asg-podtatohead-hats" {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  desired_capacity   = var.desired_instances
  max_size           = var.max_instances
  min_size           = var.min_instances
  name = "${var.podtato_name}-hats-asg"

  launch_configuration = aws_launch_configuration.podtatohead-hats.name


  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.hats_elb.id
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
    value               = "${var.podtato_name}-podtatohead-hats"
    propagate_at_launch = true
  }

}

################################################################### Load Balancer hats
resource "aws_elb" "hats_elb" {
  name = "${var.podtato_name}-hats-elb"
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  security_groups = [
    aws_security_group.elb_http_8080.id
  ]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/images/hat-01.svg"
  }

  listener {
    lb_port = 8080
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }

}