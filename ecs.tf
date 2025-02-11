
provider "aws" {
  region = "ap-south-1"  
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::992382549591:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS"

  container_definitions = jsonencode([{
    name      = "example-container"
    image     = "nginx:latest"  # Replace with your container image
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_lb_target_group" "example" {
  name     = "surajtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-01dcbc1773873e8bf"  # Replace with your VPC ID
  target_type = "ip"  # Ensure this is set to 'ip' for Fargate

  health_check {
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
  }
}

resource "aws_ecs_service" "example" {
  name            = "myecs"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0f8347458ac332e93"]  # Replace with your subnet IDs
    security_groups = ["sg-0ce7793976feda023"]  # Replace with your security group ID
    assign_public_ip = true
  }
  # Ensure the GitHub App has proper access to the repository.
}
