[
  {
    "name": "${task_name}",
    "image": "${image_name}",
    "essential": true, 
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port}
      }
    ],
    "memory": ${memory},
    "cpu": ${cpu},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${log_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]