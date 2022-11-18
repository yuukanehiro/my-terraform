# =========================================
# GCPへバックアップ用 CodeBuild ビルドプロジェクト
#
# GitLab Runnerの役割
# =========================================

# ドメインプロキシ用ビルドプロジェクト
resource "aws_codebuild_project" "backup_to_gcp_cd" {
  // プロジェクトの設定
  name          = "${local.project_name_backup_to_gcp}-ci-${var.ENV_VALUE_ENVIRONMENT}"
  description   = "continuous integration project for terraform repogistory"
  badge_enabled = false

  // ソース
  source {
    type                = "CODECOMMIT"
    location            = var.aws_codecommit_repository_sample_backup_to_gcp_cicd.repository_name
    git_clone_depth     = 1
    report_build_status = true // リポジトリ側へ結果通知
    buildspec           = "buildspec-cicd.yml"
  }
  source_version = "refs/heads/${var.ENV_VALUE_ENVIRONMENT}"

  // 環境
  environment {
    image           = "${var.backup_to_gcp_codebuild_image}" // カスタムイメージURL
    type            = "LINUX_CONTAINER"                      // 環境タイプ
    compute_type    = "BUILD_GENERAL1_SMALL"                 // コンピューティングタイプ
    privileged_mode = true                                   // Docker内でコマンドを実行する為に必要

    environment_variable {
      name  = var.ENV_NAME_ENVIRONMENT
      value = var.ENV_VALUE_ENVIRONMENT
    }
    environment_variable {
      name  = var.ENV_NAME_TF_VERSION
      value = var.ENV_VALUE_TF_VERSION
    }
  }

  service_role = var.codebuild_service_role_arn
  // タイムアウト
  build_timeout = "30"
  // キュータイムアウト
  queued_timeout = "60"

  // アーティファクト
  artifacts {
    type = "NO_ARTIFACTS"
  }

  // キャッシュ
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_SOURCE_CACHE"]
  }

  // ログ
  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = aws_cloudwatch_log_group.backup_to_gcp_cd_codepipeline.name
    }
    s3_logs {
      status = "DISABLED"
    }
  }
  lifecycle {
    ignore_changes = [
      source,
    ]
  }
}
