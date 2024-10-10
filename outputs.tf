output "id" {
  value = aws_lambda_function.this.id
}

output "arn" {
  value = aws_lambda_function.this.arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "function_version" {
  value = aws_lambda_function.this.version
}

output "qualified_arn" {
  value = aws_lambda_function.this.qualified_arn
}
