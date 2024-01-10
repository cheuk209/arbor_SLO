resource "aws_ecs_cluster" "cluster" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "classroom-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "classroom-container",
    image = "527712567356.dkr.ecr.eu-west-1.amazonaws.com/my-arbor-repo:classroom-attendance",
    portMappings = [
        {
            containerPort = 80,
            hostPort      = 80
        }
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/ecs-log-group"
        awslogs-region        = "eu-west-1"
        awslogs-stream-prefix = "ecs"
      }
    }
    environment = [
        {
            name  = "DB_HOST",
            value = aws_db_instance.my_db.address
        },
        {
            name  = "DB_USER",
            value = "admin"
        },
        {
            name  = "DB_PASS",
            value = "pleasegivemeajob"  # would be encrypted by aws secrets manager or parameter store
        },
        {
            name  = "DB_NAME",
            value = "mydatabase" 
        }
    ]
    # secret manager if I had more time and money
    # secrets = [
    #     {"name": "DATABASE_HOST", "valueFrom": "${data.aws_secretsmanager_secret.postgres.arn}:host::"},
    #     {"name": "DATABASE_PORT", "valueFrom": "${data.aws_secretsmanager_secret.postgres.arn}:port::"},
    #     {"name": "DATABASE_USERNAME", "valueFrom": "${data.aws_secretsmanager_secret.postgres.arn}:username::"},
    #     {"name": "DATABASE_PASSWORD", "valueFrom": "${data.aws_secretsmanager_secret.postgres.arn}:password::"},
    # ]
  }])
}

resource "aws_ecs_service" "service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
    security_groups = [aws_security_group.sg.id]
  }

  desired_count = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "classroom-container"
    container_port   = 80
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "ecr_read_policy" {
  name        = "ecr_read_policy"
  description = "A policy that allows ECS tasks to pull images from ECR."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "*"
      },
    ],
  })
}


resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "cloudwatch_logs_policy"
  description = "A policy that allows ECS tasks to send logs to CloudWatch."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr_read_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecr_read_policy.arn
}