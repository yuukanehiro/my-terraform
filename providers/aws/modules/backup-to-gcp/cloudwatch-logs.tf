# cidepipelineのログ
resource "aws_cloudwatch_log_group" "backup_to_gcp_cd_codepipeline" {
  name = "/codebuild/${var.ENV_VALUE_ENVIRONMENT}/${local.project_name_backup_to_gcp}/codepipeline"
  retention_in_days = var.ENV_VALUE_ENVIRONMENT == "production" ? 180 : 7

  lifecycle {
    create_before_destroy = true
  }
}

# ECS ログ
resource "aws_cloudwatch_log_group" "backup_to_gcp_cd_ecs" {
  name = "/ecs/${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"
  retention_in_days = var.ENV_VALUE_ENVIRONMENT == "production" ? 180 : 7

  lifecycle {
    create_before_destroy = true
  }
}

