variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "dr_region" {
  description = "Disaster recovery region — ECR images will be replicated here from the primary region"
  type        = string
  default     = "us-east-2"
}
