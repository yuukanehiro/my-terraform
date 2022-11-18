resource "aws_ssm_parameter" "backup_to_gcp_ecs_aws_access_key_id" {
  name  = "/sample/ecs/backup-to-gcp/${var.ENV_VALUE_ENVIRONMENT}/aws-access-key-id"
  value = "xxxxx" # 初期値。コンソール側で手動で更新して利用する aws_iam_user.backup_to_gcp_ecsのaccess_key_id
  type  = "String"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
resource "aws_ssm_parameter" "backup_to_gcp_ecs_aws_access_key_secret" {
  name  = "/sample/ecs/backup-to-gcp/${var.ENV_VALUE_ENVIRONMENT}/aws-access-key-secret"
  value = "xxxxx" # 初期値。コンソール側で手動で更新して利用する aws_iam_user.backup_to_gcp_ecsのaccess_key_secret
  type  = "String"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
