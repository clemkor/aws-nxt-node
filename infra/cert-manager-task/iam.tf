data "aws_iam_policy_document" "events_assume_role_policy_document" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["events.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "events_role_policy_document" {
  statement {
    actions = [
      "ecs:RunTask"
    ]

    resources = ["${aws_ecs_task_definition.cert_manager.arn}"]

    condition {
      test = "ArnLike"
      values = ["${data.terraform_remote_state.cluster.cluster_id}"]
      variable = "ecs:cluster"
    }
  }
}

resource "aws_iam_role" "events_role" {
  description = "Cloudwatch events role (region: ${var.region}, deployment identifier: ${var.deployment_identifier})"
  assume_role_policy = "${data.aws_iam_policy_document.events_assume_role_policy_document.json}"
}

resource "aws_iam_policy" "events_role_policy" {
  description = "Cloudwatch events policy (region: ${var.region}, deployment identifier: ${var.deployment_identifier})"
  policy = "${data.aws_iam_policy_document.events_role_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "events_role_policy_attachment" {
  policy_arn = "${aws_iam_policy.events_role_policy.arn}"
  role = "${aws_iam_role.events_role.name}"
}


data "aws_iam_policy_document" "task_assume_role_policy_document" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "task_role_policy_document" {
  statement {
    actions = [
      "route53:GetChange"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.secrets_bucket_name}/${data.template_file.env_key.rendered}"
    ]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${data.terraform_remote_state.common.public_dns_zone_id}"
    ]
  }
}

resource "aws_iam_role" "task_role" {
  description = "Cert manager task role (region: ${var.region}, deployment identifier: ${var.deployment_identifier})"
  assume_role_policy = "${data.aws_iam_policy_document.task_assume_role_policy_document.json}"
}

resource "aws_iam_policy" "task_role_policy" {
  description = "Cert manager task policy (region: ${var.region}, deployment identifier: ${var.deployment_identifier})"
  policy = "${data.aws_iam_policy_document.task_role_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  policy_arn = "${aws_iam_policy.task_role_policy.arn}"
  role = "${aws_iam_role.task_role.name}"
}
