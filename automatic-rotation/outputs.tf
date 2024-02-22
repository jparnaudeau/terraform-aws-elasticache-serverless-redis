output "lambda-rotation-infos" {
  description = "The informations related to the lambda in charge of the password rotation"
  value = {
    arn          = aws_lambda_function.default.arn
    iam_role_arn = aws_iam_role.default.arn
    secrets      = [for secret in var.secrets : secret.secret_id]
  }
}
