terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────
# Variables
# ─────────────────────────────────────────

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "index.handler"
}

# ─────────────────────────────────────────
# IAM Role for Lambda
# ─────────────────────────────────────────

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.function_name}_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ─────────────────────────────────────────
# Lambda Deployment Package
# ─────────────────────────────────────────

# Zips the local source code directory for deployment
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"   # Put your Lambda code in ./src/
  output_path = "${path.module}/lambda_function.zip"
}

# ─────────────────────────────────────────
# Lambda Function
# ─────────────────────────────────────────

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = var.runtime
  handler          = var.handler
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 30   # seconds
  memory_size = 128  # MB

  environment {
    variables = {
      ENV = "production"
    }
  }

  tags = {
    Name        = var.function_name
    ManagedBy   = "Terraform"
  }
}

# ─────────────────────────────────────────
# CloudWatch Log Group
# ─────────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

# ─────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN (useful for API Gateway integration)"
  value       = aws_lambda_function.this.invoke_arn
}
