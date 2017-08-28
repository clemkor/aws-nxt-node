data "template_file" "image" {
  template = "$${repository_url}:$${tag}"

  vars {
    repository_url = "${data.terraform_remote_state.image_repository.repository_url}"
    tag = "${var.version_number}"
  }
}

data "template_file" "task_container_definitions" {
  template = "${file("${path.root}/container-definitions/nxt-node.json.tpl")}"

  vars {
    secrets_bucket_name = "${data.terraform_remote_state.secrets_bucket.bucket_name}"

    peer_server_port = "${var.peer_server_port}"
    ui_server_port = "${var.ui_server_port}"
    api_server_port = "${var.api_server_port}"
  }
}

module "service" {
  source = "github.com/infrablocks/terraform-aws-ecs-service?ref=0.1.3//src"

  region = "${var.region}"
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  service_name = "${var.component}"
  service_image = "${data.template_file.image.rendered}"
  service_port = "${var.peer_server_port}"

  service_task_container_definitions = "${data.template_file.task_container_definitions.rendered}"

  service_desired_count = "${var.desired_count}"
  service_deployment_maximum_percent = "${var.deployment_maximum_percent}"
  service_deployment_minimum_helathy_percent = "${var.deployment_minimum_healthy_percent}"

  service_elb_name = "${module.load_balancer.name}"

  ecs_cluster_id = "${data.terraform_remote_state.cluster.cluster_id}"
  ecs_cluster_service_role_arn = "${data.terraform_remote_state.cluster.service_role_arn}"
}
