# Creates Private TG 
resource "aws_lb_target_group" "app" {
  name     = "${var.COMPONENT}-${var.ENV}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.VPC_ID 

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    enabled             = true
    interval            = 5
    timeout             = 4
  }
}

# Now attachi instances to the created target.
resource "aws_lb_target_group_attachment" "instance-attach" {
  count            = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = element(local.ALL_INSTANCE_IDS, count.index)
  port             = var.APP_PORT
}

# Private Listener rules
# Public Listener , creates only if the LB_TYPE is internal
resource "aws_lb_listener_rule" "app_rule" {
  count        = var.LB_TYPE == "internal" ? 1 : 0

  listener_arn = data.terraform_remote_state.alb.outputs.PRIVATE_LISTENER_ARN
  priority     = random_integer.lb-rule-priority.result

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    host_header {
      values = ["${var.COMPONENT}-${var.ENV}.${data.terraform_remote_state.vpc.outputs.HOSTEDZONE_PRIVATE_ZONE}"]
    }
  }
}

# Generating a random number for lb rule in the range of 100 to 500 ;
resource "random_integer" "lb-rule-priority" {
  min = 100
  max = 500
}


# Public Listener , creates only if the LB_TYPE is Public
resource "aws_lb_listener" "public_lb_listener" {
  count             = var.LB_TYPE == "public" ? 1 : 0
  load_balancer_arn = data.terraform_remote_state.alb.outputs.PUBLIC_ALB_ARN
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}