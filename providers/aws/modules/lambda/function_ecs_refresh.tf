# 空のlambdaを作成する為のdummyソースコードとなるリソース
resource "aws_lambda_function" "ecs_refresh" {
  function_name = "ecs-refresh-${var.ENV_VALUE_ENVIRONMENT}"
  role          = "${aws_iam_role.ecs_refresh.arn}"

  handler  = "function.lambda_handler"
  runtime  = "python3.9"
  filename = data.archive_file.dummy.output_path
  memory_size   = 256
  timeout       = 30
  environment {
    variables = {
      "${var.ENV_NAME_SLACK_CHANNEL_NAME_NOTICE}" = "${var.ENV_VALUE_SLACK_CHANNEL_NAME_NOTICE}"
      "${var.ENV_NAME_SLACK_WEBHOOK_URL}" = "${var.ENV_VALUE_SLACK_WEBHOOK_URL}"
      DEPLOY_APP_NAMES = "" // ex. "app-A,app-B"
      ENVIRONMENT = "${var.ENV_VALUE_ENVIRONMENT}"
    }
  }
}

resource "aws_s3_bucket" "ecs_refresh" {
  bucket = "ecs-refresh-${var.ENV_VALUE_ENVIRONMENT}"
}
resource "aws_s3_bucket_acl" "ecs_refresh" {
  bucket = aws_s3_bucket.ecs_refresh.id
  acl    = "private"
}


resource "aws_iam_role" "ecs_refresh" {
  name               = "ecs-refresh-${var.ENV_VALUE_ENVIRONMENT}"
  assume_role_policy = file("${path.module}/policy/assume-lambda.json")
}
resource "aws_iam_policy" "ecs_refresh" {
  name   = "ecs-refresh-${var.ENV_VALUE_ENVIRONMENT}"
  policy = file("${path.module}/policy/ecs-refresh-policy.json")
}
resource "aws_iam_role_policy_attachment" "ecs_refresh" {
  role       = aws_iam_role.ecs_refresh.name
  policy_arn = aws_iam_policy.ecs_refresh.arn
}

# Event Bridge
resource "aws_cloudwatch_event_rule" "ecs_refresh_start" {
  name                = "ecs-refresh-start-${var.ENV_VALUE_ENVIRONMENT}"
  description         = "ECS Refresh"
  schedule_expression = "cron(0 18 ? * MON-SUN *)" // 初期値 cron(Minutes Hours Day-of-month Month Day-of-week Year)
  # コンソールで変更できるようにする
  lifecycle {
    ignore_changes = [
      schedule_expression,
      is_enabled
    ]
  }
}
resource "aws_cloudwatch_event_target" "ecs_refresh_start" {
  rule      = "${aws_cloudwatch_event_rule.ecs_refresh_start.name}"
  target_id = "ecs-refresh-start-${var.ENV_VALUE_ENVIRONMENT}"
  arn       = "${aws_lambda_function.ecs_refresh.arn}"

  depends_on = [
    aws_lambda_function.ecs_refresh
  ]
}
resource "aws_lambda_permission" "allow_ecs_refresh" {
  statement_id  = "rds-manager-by-tag-stop-${var.ENV_VALUE_ENVIRONMENT}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ecs_refresh.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ecs_refresh_start.arn}"
}
