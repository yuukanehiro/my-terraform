ENV_NAME_ENVIRONMENT  = "ENVIRONMENT"
ENV_VALUE_ENVIRONMENT = "develop"

# Lambda
ENV_NAME_SLACK_CHANNEL_NAME_NOTICE = "SLACK_CHANNEL_NAME_NOTICE"
ENV_VALUE_SLACK_CHANNEL_NAME_NOTICE = "system-notice"
ENV_NAME_SLACK_WEBHOOK_URL = "SLACK_WEBHOOK_URL"
ENV_VALUE_SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/xxxxx/yyyyy/zzzzz"
MANAGER_BY_TAG_INPUT_JSON_START = <<JSON
{"region": "ap-northeast-1","action": "start","app_env": "dev"}
JSON
MANAGER_BY_TAG_INPUT_JSON_STOP = <<JSON
{"region": "ap-northeast-1","action": "stop","app_env": "dev"}
JSON

# ==================
# GCPへのバックアップ
# ==================
default_vpc_id = "vpc-xxxxx"
backup_to_gcp_codebuild_image = "aws/codebuild/standard:5.0" # Ubuntu 20.04
# バックアップ元S3
backup_to_gcp_source_s3_list_bucket_arns = [
  "arn:aws:s3:::sample-backup-develop"
]
backup_to_gcp_source_s3_get_object_arns = [
  "arn:aws:s3:::sample-backup-develop/*"
]