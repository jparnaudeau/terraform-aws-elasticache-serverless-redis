######################################
# Retrieve some informations from STS Session
# to generate dynamically arn and other stuff
######################################
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "secretmanager" {
  statement {
    sid = "SecretsManagerOperations"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    condition {
      test     = "StringEquals"
      variable = "secretsmanager:resource/AllowRotationLambdaArn"
      values   = ["arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.default.function_name}"]
    }
    resources = [for secret in var.secrets : secret.secret_arn]
  }

  statement {
    sid       = "SecretsManagerGeneratePassword"
    actions   = ["secretsmanager:GetRandomPassword"]
    resources = ["*"]
  }

  statement {
    sid = "KMSOperations"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]
    resources = [var.kms_key_id]
  }

  statement {
    sid = "RedisOperations"
    actions = [
      "elasticache:DescribeUsers",
      "elasticache:ModifyUser",
    ]
    resources = [for secret in var.secrets : secret.redis_user_arn]
  }
}


##################################
# Create a dedicated role for our Lambda
##################################
data "aws_iam_policy_document" "service" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  name               = format(var.name_patern, "role-lambda")
  assume_role_policy = data.aws_iam_policy_document.service.json
  tags               = var.tags
}


##################################
# Attach required Permissions for our Lambda
# AWSLambdaBasicExecutionRole : for cloudWatch Logs
# AWSLambdaVPCAccessExecutionRole : to be able to create ENI inside the VPC
# Required Permissions on SecretsManager to rotate a secret + KMS Key to decrypt/encrypt new password
##################################
resource "aws_iam_role_policy_attachment" "lambda-basic" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-vpc" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda-secretsmanager" {
  name   = "SecretsManagerRedisPasswordRotationPolicy"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.secretmanager.json
}
