data "template_file" "container_definitions" {
  template = file("${path.module}/templates/container_definitions.json.tpl")
  vars = {
    task_name                 = var.task_name
    aws_ecr_url               = var.ecr_url
    tag                       = var.container_image_version
    cloudwatch_log_group_name = var.log_group_name
    cloudwatch_log_prefix     = var.log_prefix
    region                    = var.region
    fidc_url                  = var.fidc_url
    fidc_api_key_id           = var.fidc_api_key_id
    fidc_api_key_secret       = var.fidc_api_key_secret
  }
}

resource "aws_ecs_task_definition" "monitoring" {
  family                   = var.task_name
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_task_role_arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.container_definitions.rendered
}

resource "aws_ecs_service" "monitoring" {
  name            = var.task_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.monitoring.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.ecs_task_security_group_id]
    subnets          = var.subnet_ids
    assign_public_ip = false
  }
}
