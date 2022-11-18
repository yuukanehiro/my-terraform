# ======================================================================
# GCPバックアップ用 CodePipeline CI/CD
#
# ======================================================================

resource "aws_codepipeline" "backup_to_gcp" {
  name     = "${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"
  role_arn = "${var.codepipeline_service_role_arn}"

  artifact_store {
    location = aws_s3_bucket.sample_backup_to_gcp_cicd_codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName = var.aws_codecommit_repository_sample_backup_to_gcp_cicd.repository_name
        BranchName     = "${var.ENV_VALUE_ENVIRONMENT}"
      }
    }
  }
  # 本番のみ手動承認stageを作成
  dynamic "stage" {
    for_each = var.ENV_VALUE_ENVIRONMENT == "production" ? [1] : []
    content {
      name = "Approval"
      action {
        name          = "Approval"
        category      = "Approval"
        owner         = "AWS"
        provider      = "Manual"
        version       = "1"
        configuration = {
          CustomData = "承認してください"
        }
      }
    }
  }
  stage {
    name = "Build_Docker_image_and_Push_ECR_UPDATE_ECS_task_definition"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.backup_to_gcp_cd.name
      }
    }
  }
}
