data "template_file" "image" {
  template = "$${repository_url}:$${tag}"

  vars {
    repository_url = "${data.terraform_remote_state.image_repository.repository_url}"
    tag = "${var.version_number}"
  }
}

data "template_file" "task_container_definitions" {
  template = "${file("${path.root}/container-definitions/cert-manager.json.tpl")}"

  vars {
    name = "cert-manager"
    image = "${data.template_file.image.rendered}"
    command = "[]"
    log_group = "${aws_cloudwatch_log_group.task.name}"
    aws_region = "${var.region}"
    aws_s3_configuration_object = "${data.template_file.env_url.rendered}"
  }
}

resource "aws_ecs_task_definition" "cert_manager" {
  container_definitions = "${data.template_file.task_container_definitions.rendered}"
  family = "${var.component}-${var.task_name}-${var.deployment_identifier}"

  task_role_arn = "${aws_iam_role.task_role.arn}"

  volume {
    name = "nxt-certs"
    host_path = "/opt/nxt/nxt_certs"
  }

  placement_constraints {
    type = "memberOf"
    expression = "task:group == service:nxt"
  }
}