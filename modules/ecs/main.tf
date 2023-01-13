# ECS has three parts: cluster, service and tasks 

resource "aws_ecs_cluster" "my_cluster" {
  name = var.cluster_name
}

# resource "aws_ecs_service"

resource "aws_ecs_task_definition" "node" {
  family                   = "node"
  container_definitions    = templatefile("${path.module}/templates/ecs_template.tpl",{
    task_name = var.task_name,
    image_name = var.image_name,
    container_port = var.container_port,
    host_port = var.host_port,
    memory = var.memory,
    cpu = var.cpu,
    log_group = aws_cloudwatch_log_group.application_log.name,
    log_region = var.region
  })
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_to_ecs_role" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "helloworld_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.node.arn
  launch_type     = "FARGATE"
  desired_count   = var.number_of_container
  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups = [aws_security_group.ecs.id]
  }
  load_balancer {
    container_name = aws_ecs_task_definition.node.family
    container_port = 3000
    target_group_arn = var.target_group_arn
  }
}

resource "aws_cloudwatch_log_group" "application_log" {
  name = "ecs/helloworld"
  retention_in_days = 7
  tags = {
    Name = "helloworld-log-group"
  } 
}

resource "aws_cloudwatch_log_stream" "application_log_stream" {
  log_group_name = aws_cloudwatch_log_group.application_log.name
  name = "ecs-node"
}

resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [var.security_group_id_alb]
  }

  egress {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  name = "alb-ecs"
}