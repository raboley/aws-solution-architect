resource "aws_lb" "i" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.vpc.vpc_public_security_group_id]
  subnets            = [module.subnets_b.vpc_public_subnet_id, module.subnets_a.vpc_public_subnet_id]

}

resource "aws_lb_target_group" "i" {
  vpc_id = module.vpc.vpc_id
  name   = "MyWPInstances"

  target_type = "instance"
  port        = 80
  protocol    = "HTTP"

  health_check {
    protocol = "HTTP"
    path     = "/healthy.html"

    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 6
    matcher             = "200"
  }
}

// Don't want to have the write node in the list of load balancers
//resource "aws_lb_target_group_attachment" "i" {
//  target_group_arn = aws_lb_target_group.i.arn
//  target_id        = aws_instance.public.id
//  port             = 80
//}

resource "aws_lb_listener" "i" {
  load_balancer_arn = aws_lb.i.arn
  port              = 80
  default_action {
    target_group_arn = aws_lb_target_group.i.arn
    type             = "forward"
  }
}
