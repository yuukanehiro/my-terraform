# ==================================================================
# GCPへバックアップタスク用 ECS
#
# ==================================================================

# ECS Cluster
# https://ap-northeast-1.console.aws.amazon.com/ecs/home?region=ap-northeast-1#/clusters
# Cluster ... 箱
resource "aws_ecs_cluster" "backup_to_gcp" {
  name = "${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"
}

# タスク定義
# https://ap-northeast-1.console.aws.amazon.com/ecs/home?region=ap-northeast-1#/taskDefinitions
# タスク ... EC2的なもの
resource "aws_ecs_task_definition" "backup_to_gcp" {
  family = "${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"

  # データプレーンの選択
  requires_compatibilities = ["FARGATE"]
  # ロール設定
  task_role_arn            = aws_iam_role.backup_to_gcp_ecs.arn # コンテナ内の権限, S3やSESなどの権限をつける。EC2のIAM Profileと同義
  execution_role_arn       = aws_iam_role.backup_to_gcp_ecs.arn # コンテナ外の権限, ECRやParameter Storeの権限をつける

  # ECSタスクが使用可能なリソースの上限
  # タスク内のコンテナはこの上限内に使用するリソースを収める必要があり、メモリが上限に達した場合OOM Killer にタスクがキルされる
  cpu    = "2048" # 初期値
  memory = "4096" # 初期値

  # ECSタスクのネットワークドライバ
  # Fargateを使用する場合は"awsvpc"決め打ち
  network_mode = "awsvpc"

  # 起動するコンテナの定義
  # 「nginxを起動し、443ポートを開放する」設定を記述。
  container_definitions = <<EOL
[
  {
    "dnsSearchDomains": null,
    "environmentFiles": null,
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "/ecs/${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "entryPoint": null,
    "portMappings": [],
    "command": null,
    "linuxParameters": null,
    "cpu": 0,
    "environment": [],
    "resourceRequirements": null,
    "ulimits": null,
    "dnsServers": null,
    "mountPoints": [],
    "workingDirectory": null,
    "secrets": null,
    "dockerSecurityOptions": null,
    "memory": null,
    "memoryReservation": null,
    "volumesFrom": [],
    "stopTimeout": null,
    "image": "${aws_ecr_repository.backup_to_gcp.repository_url}:latest",
    "startTimeout": null,
    "firelensConfiguration": null,
    "dependsOn": null,
    "disableNetworking": null,
    "interactive": null,
    "healthCheck": null,
    "essential": true,
    "links": null,
    "hostname": null,
    "extraHosts": null,
    "pseudoTerminal": null,
    "user": null,
    "readonlyRootFilesystem": null,
    "dockerLabels": null,
    "systemControls": null,
    "privileged": null,
    "name": "${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"
  }
]
EOL

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      container_definitions,
      cpu,
      memory
    ]
  }
}

