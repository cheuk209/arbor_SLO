resource "aws_lb" "alb" {
    name               = "my-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.sg.id]
    subnets            = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }
}

resource "aws_lb_target_group" "tg" {
    name     = "my-target-group"
    port     = 80
    target_type = "ip"
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id

    health_check {
        enabled = true
        path    = "/"
        port    = "traffic-port"
        protocol = "HTTP"
    }
}

resource "aws_security_group" "sg" {
    name        = "lb-security-group"
    description = "Security group for load balancer"
    vpc_id      = aws_vpc.main.id

    # http
    ingress { 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    # https
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}
