# sample-lambda
resource "aws_codecommit_repository" "sample_lambda" {
  repository_name = "sample-lambda"
}

# GCPへのバックアップ用リポジトリ
resource "aws_codecommit_repository" "backup_to_gcp_cicd" {
  repository_name = "sample-backup-to-gcp-cicd"
  description     = "ECRへのDocker imageのプッシュとデプロイ"
}