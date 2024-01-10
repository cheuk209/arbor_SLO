output "repository_url" {
  value = aws_ecr_repository.repository.repository_url
  description = "The URL of the ECR repository."
}

output "repository_arn" {
  value = aws_ecr_repository.repository.arn
  description = "The ARN of the ECR repository."
}