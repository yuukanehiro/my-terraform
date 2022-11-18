resource "aws_cloudwatch_event_target" "backup_to_gcp" {
  rule     = "${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"
  arn      = aws_ecs_cluster.backup_to_gcp.arn
  role_arn = aws_iam_role.ecs_scheduled_task.arn
  ecs_target {
    # リビジョンなしのARNを指定することで常に最新になる
    task_definition_arn = replace(aws_ecs_task_definition.backup_to_gcp.arn, "/:\\d+$/", "")
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = [
        "${local.subnet_default_c}"
      ]
      security_groups  = [
        aws_security_group.backup_to_gcp.id
      ]
      assign_public_ip = true
    }
  }
  depends_on = [
    aws_cloudwatch_event_rule.backup_to_gcp
  ]
}

resource "aws_cloudwatch_event_rule" "backup_to_gcp" {
  name                = "${local.project_name_backup_to_gcp}-${var.ENV_VALUE_ENVIRONMENT}"
  schedule_expression = "cron(0 * * * ? *)" # 初期値。コンソールで更新する

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      schedule_expression
    ]
  }
}