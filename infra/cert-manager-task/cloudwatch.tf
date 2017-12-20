

resource "aws_cloudwatch_log_group" "task" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-task/${var.task_name}"

  tags {
    Environment = "${var.deployment_identifier}"
    Component = "${var.component}"
    Task = "${var.task_name}"
  }
}

resource "aws_cloudwatch_event_rule" "once_monthly_events" {
  name = "once-monthly-event-${var.region}-${var.deployment_identifier}"
  description = "A scheduled event running once-monthly (region: ${var.region}, deployment identifier: ${var.deployment_identifier})"

  schedule_expression = "rate(30 days)"
}

resource "aws_cloudwatch_event_target" "once_monthly_cert_manager_target" {
  rule = "${aws_cloudwatch_event_rule.once_monthly_events.name}"
  arn = "${data.terraform_remote_state.cluster.cluster_id}"

  role_arn = "${aws_iam_role.events_role.arn}"

  ecs_target {
    task_count = 1
    task_definition_arn = "${aws_ecs_task_definition.cert_manager.arn}"
  }
}
