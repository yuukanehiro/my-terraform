# ==============================
# セキュリティグループ
# ==============================

resource "aws_security_group" "backup_to_gcp" {
  name        = "${local.project_name_backup_to_gcp}-gcloud-sdk-${var.ENV_VALUE_ENVIRONMENT}"
  description = "${local.project_name_backup_to_gcp}-gcloud-sdk-${var.ENV_VALUE_ENVIRONMENT}"

  # セキュリティグループを配置するVPC
  vpc_id      = "${var.default_vpc_id}"

  # セキュリティグループ内のリソースからインターネットへのアクセス許可設定
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name_backup_to_gcp}-gcloud-sdk-${var.ENV_VALUE_ENVIRONMENT}"
  }
}