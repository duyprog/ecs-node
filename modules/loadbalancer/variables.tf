variable "name" {
    type = string
    description = "Name of this load balancer"
}

variable "subnets" {
  type = list(string)
  description = "Subnets list use for this load balancer"
}

variable "vpc_id" {
  type = string 
  description = "VPC that ALB been placed"
}