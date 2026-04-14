# ─────────────────────────────────────────
# Variables
# ─────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "my_lambda_function"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Lambda handler (filename.function_name)"
  type        = string
  default     = "lambda_function.lambda_handler"
}
