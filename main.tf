data "aws_region" "current" {}

locals {
  resources_path = "${path.module}/resources"
}

data "external" "npm_build" {
  program = [
    "bash", "-c", <<EOT
(npm ci && npm run build) >&2 && echo "{\"filename\": \"index.js\"}"
EOT
  ]
  working_dir = local.resources_path
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "${local.resources_path}/dist/${data.external.npm_build.result.filename}"
  output_path = "${local.resources_path}/lambda.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  description   = var.description

  role = aws_iam_role.this.arn

  publish = true

  runtime       = "nodejs20.x"
  architectures = ["arm64"]

  memory_size = var.memory_size

  handler = "index.handler"

  package_type     = title(data.archive_file.zip.type)
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  logging_config {
    log_format            = var.logging_config.log_format
    application_log_level = var.logging_config.application_log_level
    system_log_level      = var.logging_config.system_log_level
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}
