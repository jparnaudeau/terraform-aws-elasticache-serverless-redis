locals {
  filename           = "SecretsManagerElasticacheUserRotation.zip"
  lambda_description = "Conducts an AWS SecretsManager secret rotation for AWS Elasticache Redis using redis user rotation scheme"

}

# Important Note : AWS provide the lambda code for the rotation : 
# https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas/blob/master/SecretsManagerElasticacheUserRotation/lambda_function.py
resource "aws_lambda_function" "default" {
  description      = local.lambda_description
  filename         = "${path.module}/functions/${local.filename}"
  source_code_hash = filebase64sha256("${path.module}/functions/${local.filename}")
  function_name    = format(var.name_patern, "lambda")
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = var.timeout
  role             = aws_iam_role.default.arn
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  environment {
    variables = { #https://docs.aws.amazon.com/general/latest/gr/rande.html#asm_region
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
      SECRET_ARNS              = join(",", [for secret in var.secrets : secret.secret_arn])
      USER_NAMES               = join(",", [for secret in var.secrets : secret.redis_user_name])
    }
  }
  tags = var.tags
}

resource "aws_lambda_permission" "default" {
  function_name = aws_lambda_function.default.function_name
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}


resource "aws_secretsmanager_secret_rotation" "default" {
  for_each = { for secret in var.secrets : secret.secret_id => secret }

  secret_id           = each.value.secret_id
  rotation_lambda_arn = aws_lambda_function.default.arn
  rotation_rules {
    automatically_after_days = try(each.value.rotation_days, 90)
  }
}

