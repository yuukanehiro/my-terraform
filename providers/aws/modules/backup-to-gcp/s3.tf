# CodePipeline用バケット
resource "aws_s3_bucket" "sample_backup_to_gcp_cicd_codepipeline_bucket" {
  bucket = "${local.project_name_backup_to_gcp}-cicd-codepipeline-${var.ENV_VALUE_ENVIRONMENT}"
}
# CodePipeline用バケットのコンフィグ ... n日経過したデータを削除
resource "aws_s3_bucket_lifecycle_configuration" "sample_backup_to_gcp_cicd_codepipeline_bucket" {
  bucket = aws_s3_bucket.sample_backup_to_gcp_cicd_codepipeline_bucket.id
  rule {
    status  = "Enabled"
    id      = "default"
    # n日経過したobjectを削除
    expiration {
      days = 7
    }
  }
  rule {
    id = "delete-over90days-versions"
    status = "Enabled"
    filter {
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  rule {
    id  = "delete-maker"
    status = "Enabled"
    expiration {
      days = 0
      expired_object_delete_marker = true
    }
    filter {
    }
  }
}
resource "aws_s3_bucket_acl" "sample_backup_to_gcp_cicd_codepipeline_bucket" {
  bucket = aws_s3_bucket.sample_backup_to_gcp_cicd_codepipeline_bucket.id
  acl    = "private"
}