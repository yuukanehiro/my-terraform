# S3->GCP 実行用ユーザ ... GCPのSDKはRoleから取得したACCESS_KEY_IDでは動作しない仕様なので、Userを発行する必要がある
resource "aws_iam_user" "backup_to_gcp_ecs" {
  name          = "${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"
  # Accessキーの削除・更新ができるようにする
  force_destroy = true
}
resource "aws_iam_policy" "backup_to_gcp_ecs" {
  name        = "${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "${var.backup_to_gcp_source_s3_list_bucket_arns}"
        },
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "${var.backup_to_gcp_source_s3_get_object_arns}"
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetAuthorizationToken",
                "ecr:BatchGetImage",
                "ecs:ListContainerInstances",
                "ecs:DescribeContainerInstances",
                "ecs:ListClusters",
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:ssm:ap-northeast-1:091803464063:parameter/sample/ecs/backup-to-gcp/${var.ENV_VALUE_ENVIRONMENT}/aws-access-key-id",
                "arn:aws:ssm:ap-northeast-1:091803464063:parameter/sample/ecs/backup-to-gcp/${var.ENV_VALUE_ENVIRONMENT}/aws-access-key-secret"
            ]
        }
    ]
})
  description = "S3からGCSへファイル転送する"
}
resource "aws_iam_user_policy_attachment" "backup_to_gcp_ecs_policy_attach_backup_to_gcp_ecs_user" {
  user       = aws_iam_user.backup_to_gcp_ecs.name
  policy_arn = aws_iam_policy.backup_to_gcp_ecs.arn
}


# ECS Role
resource "aws_iam_role" "backup_to_gcp_ecs" {
  name               = "sync-backup-data-from-s3-to-gcs-role-${var.ENV_VALUE_ENVIRONMENT}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "backup_to_gcp_ecs_attach_policy" {
  role       = aws_iam_role.backup_to_gcp_ecs.name
  policy_arn = aws_iam_policy.backup_to_gcp_ecs.arn
}

# Event BridgeからECSを起動させる
resource "aws_iam_role" "ecs_scheduled_task" {
  name = "${local.project_name_backup_to_gcp}-run-ecs-task-${var.ENV_VALUE_ENVIRONMENT}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "allow_pass_role"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ecs:RunTask"
          ],
          "Resource": [
            # リビジョンを指定しないことでlatestになる
            replace(aws_ecs_task_definition.backup_to_gcp.arn, "/:\\d+$/", "")
          ],
          "Condition": {
            "ArnLike": {
              "ecs:cluster": aws_ecs_cluster.backup_to_gcp.arn
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": [
            aws_iam_role.backup_to_gcp_ecs.arn
          ],
          "Condition": {
            "StringLike": {
              "iam:PassedToService": "ecs-tasks.amazonaws.com"
            }
          }
        }
      ]
    })
  }
}
