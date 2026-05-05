provider "aws" {
  region = var.aws_region
}

locals {
  account_id = "005654795190"

  # Repository policy: allows the IAM user full ECR access
  ecr_repository_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:user/Abdul"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      }
    ]
  })

  # Lifecycle policy: keep only the 2 most recent images (POC/test limit)
  ecr_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the 2 most recent images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 2
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # All repo names to replicate to the DR region.
  # Add or remove entries here as repos grow — no need
  # to touch the module call or module source.
  repos_to_replicate = [
    "demo-bank-app",
    "my-node-app",
    "my-nginx-app",
    # ... add more repos here
  ]

  # Build the replication rules list from the repo names above.
  # Each repo gets its own PREFIX_MATCH rule pointing to the DR region.
  replication_rules = [
    for repo in local.repos_to_replicate : {
      destination_region         = var.dr_region
      destination_registry_id    = local.account_id
      replicate_all_repositories = false
      repository_filter_value    = repo
      repository_filter_type     = "PREFIX_MATCH"
    }
  ]
}

#--------------------------------------------------
# demo-bank-app ECR repository
# Owns the registry-level replication singleton.
# create_replication_config = true on this call ONLY.
#--------------------------------------------------
module "ecr_demo_bank_app" {
  source = "./modules/ecr"

  name                 = "demo-bank-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration = {
    scan_on_push = true
  }

  repository_policy = local.ecr_repository_policy
  lifecycle_policy  = local.ecr_lifecycle_policy

  create_replication_config      = true
  cross_region_replication_rules = local.replication_rules

  tags = {
    Project     = "demo-bank-app"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

#--------------------------------------------------
# my-node-app ECR repository
# create_replication_config = false — singleton
# already owned by ecr_demo_bank_app above.
#--------------------------------------------------
module "ecr_my_node_app" {
  source = "./modules/ecr"

  name                 = "my-node-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration = {
    scan_on_push = true
  }

  repository_policy = local.ecr_repository_policy
  lifecycle_policy  = local.ecr_lifecycle_policy

  create_replication_config = false

  tags = {
    Project     = "my-node-app"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

#--------------------------------------------------
# my-nginx-app ECR repository
#--------------------------------------------------
module "ecr_my_nginx_app" {
  source = "./modules/ecr"

  name                 = "my-nginx-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration = {
    scan_on_push = true
  }

  repository_policy = local.ecr_repository_policy
  lifecycle_policy  = local.ecr_lifecycle_policy

  create_replication_config = false

  tags = {
    Project     = "my-nginx-app"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
