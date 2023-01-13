variable "cluster_name" {
  description = "Name of ECS cluster"
  type        = string
}

variable "task_name" {
  description = "Name of ECS Task"
}

variable "service_name" {
  description = "Name of ECS Service"
  type        = string
}

variable "image_name" {
  description = "Image name of ECS task"
  type        = string
}

variable "subnets" {
  description = "Subnets list of VPC in which we will deploy application"
  type        = list(string)
}

variable "number_of_container" {
  description = "The number of container we want to deploy on each service"
  type        = number
}

variable "cpu" {
  description = "Cpu use for container"
  type        = number
  default     = 256
}

variable "memory" {
  type        = number
  description = "Memory use for container"
  default     = 512
}

variable "container_port" {
  type        = number
  description = "Port expose by container"
}

variable "host_port" {
  type        = number
  description = "Port on host to connect to container port (mapping)"
}

variable "region" {
  type = string 
  description = "hehe"
  default = "ap-southeast-1"
}

variable "target_group_arn" {
  type = string
  description = "Target group to link ecs service to ALB"
}

variable "vpc_id" {
  type = string
  description = "VPC ID of security group"
}

variable "security_group_id_alb" {
  type = string 
  description = "Security group id of alb to allow access ECS"
}
