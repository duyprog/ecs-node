terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source         = "./modules/vpc"
  env            = "dev"
  vpc_cidr_block = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "alb" {
  source  = "./modules/loadbalancer"
  name    = "ecs-alb"
  subnets = module.vpc.vpc_subnet_map
  vpc_id  = module.vpc.vpc_id
}

module "ecs" {
  source                = "./modules/ecs"
  cluster_name          = "helloworld"
  container_port        = 3000
  host_port             = 3000
  image_name            = "099608707772.dkr.ecr.ap-southeast-1.amazonaws.com/node-helloworld"
  number_of_container   = 2
  service_name          = "hello-world"
  task_name             = "node"
  subnets               = module.vpc.vpc_subnet_map
  target_group_arn      = module.alb.target_group_arn
  security_group_id_alb = module.alb.security_group_id_alb
  vpc_id                = module.vpc.vpc_id
}

