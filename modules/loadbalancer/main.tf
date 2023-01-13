resource "aws_security_group" "load_balancer_security_group" {
    vpc_id = var.vpc_id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    name = "alb-sg"
}

resource "aws_lb" "application_lb" {
  name = var.name
  load_balancer_type = "application"
  subnets = var.subnets
  security_groups = [aws_security_group.load_balancer_security_group.id]
}

resource "aws_lb_target_group" "target_group" {
    name = "application-target-group"
    port = "80"
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id
    health_check {
      port = "3000"
      matcher = "200,301,302"
      path = "/"
      interval = "30"
      protocol = "HTTP"
      timeout = "5"
      unhealthy_threshold = "5"
    }   
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
