resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = module.assume_role_policy_document.json

  tags = var.tags
}

module "assume_role_policy_document" {
  source = "github.com/skrastrek/terraform-modules-aws-iam//policy-document/service-assume-role?ref=v0.2.0"

  service_identifiers = ["lambda.amazonaws.com"]
}

resource "aws_iam_role_policy_attachment" "aws_lambda_basic_execution_role" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "cognito_user_pool" {
  role   = aws_iam_role.this.id
  name   = "cognito-user-pool"
  policy = data.aws_iam_policy_document.cognito_user_pool.json
}

data "aws_iam_policy_document" "cognito_user_pool" {
  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminLinkProviderForUser",
      "cognito-idp:AdminSetUserPassword",
      "cognito-idp:ListUsers",
    ]
    resources = ["*"]
  }
}
