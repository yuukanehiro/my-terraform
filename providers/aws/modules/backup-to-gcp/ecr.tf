# CloudSDK用ECR
resource "aws_ecr_repository" "backup_to_gcp" {
  name                 = "${local.project_name_backup_to_gcp}-cloudsdk-${var.ENV_VALUE_ENVIRONMENT}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # 脆弱性スキャン
  }
}
