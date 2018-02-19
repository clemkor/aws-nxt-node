module "ecs_route53_registration" {
  source  = "infrablocks/ecs-route53-registration/aws"
  version = "0.1.4"

  region = "${var.region}"

  deployment_identifier = "${var.deployment_identifier}"

  cluster_arn = "${data.terraform_remote_state.cluster.cluster_id}"

  service_name = "${var.service_name}"
  hosted_zone_id = "${data.terraform_remote_state.common.public_dns_zone_id}"
  record_set_name_template = "${data.template_file.address.rendered}"
  record_set_ip_type = "public"
}
