locals {
    service_arn = "arn:aws:ecs:"
}

resource "aws_iam_role" "execution_role" {
    name = "restart_ecs_service_${var.ecs_service_name}"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
    EOF
}

resource "aws_iam_role_policy" "policy" {
    name = "grant_lambda_access_to_restart_ecs_service_${var.ecs_service_name}"
    role = aws_iam_role.execution_role.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = [
                "ecs:UpdateService"
            ]
            Effect = "Allow"
            Resource = [
                var.ecs_service_arn
            ]
        }]
    })
}

resource "aws_iam_role_policy_attachment" "LambdaBasicExecution" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "eventbridge" {
    statement_id = "AllowEventBridgeToExecute"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.restart_function.function_name
    principal = "events.amazonaws.com"
    qualifier = aws_lambda_alias.alias.name
    source_account = data.aws_caller_identity.current.id
}

resource "aws_lambda_alias" "alias" {
    name = "alias_restart_ecs_service_${var.ecs_service_name}"
    function_name = aws_lambda_function.restart_function.function_name
    function_version = "$LATEST"
}