module "load_balancer" {
  source = "github.com/infrablocks/terraform-aws-classic-load-balancer?ref=0.1.1//src"

  region = "${var.region}"
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"
  subnet_ids = "${split(",", data.terraform_remote_state.network.public_subnet_ids)}"

  domain_name = "${data.terraform_remote_state.common.domain_name}"
  public_zone_id = "${data.terraform_remote_state.common.public_dns_zone_id}"
  private_zone_id = "${data.terraform_remote_state.common.private_dns_zone_id}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  listeners = [
    {
      lb_port = "${var.peer_server_port}"
      lb_protocol = "TCP"
      instance_port = "${var.peer_server_port}"
      instance_protocol = "TCP"
    },
    {
      lb_port = 80
      lb_protocol = "HTTP"
      instance_port = "${var.api_server_port}"
      instance_protocol = "HTTP"
    }
  ]
  access_control = [
    {
      lb_port = "${var.peer_server_port}"
      instance_port = "${var.peer_server_port}"
      allow_cidr = "0.0.0.0/0"
    },
    {
      lb_port = 443
      instance_port = "${var.api_server_port}"
      allow_cidr = "0.0.0.0/0"
    }
  ]

  health_check_target = "TCP:${var.peer_server_port}"
  health_check_timeout = 30
  health_check_interval = 60
  health_check_unhealthy_threshold = 10
  health_check_healthy_threshold = 10

  include_public_dns_record = "yes"
  include_private_dns_record = "yes"

  expose_to_public_internet = "yes"
}