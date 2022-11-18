variable ENV_NAME_ENVIRONMENT {}
variable ENV_VALUE_ENVIRONMENT {}

# Lambda
variable ENV_NAME_SLACK_CHANNEL_NAME_NOTICE {}
variable ENV_VALUE_SLACK_CHANNEL_NAME_NOTICE {}
variable ENV_NAME_SLACK_WEBHOOK_URL {}
variable ENV_VALUE_SLACK_WEBHOOK_URL {}
variable MANAGER_BY_TAG_INPUT_JSON_START {}
variable MANAGER_BY_TAG_INPUT_JSON_STOP {}


# GCPへのバックアップ
variable default_vpc_id {}
variable backup_to_gcp_codebuild_image {}
variable backup_to_gcp_source_s3_list_bucket_arns {}
variable backup_to_gcp_source_s3_get_object_arns {}