resource "aws_route53_record" "public" {
  zone_id = "${data.terraform_remote_state.common.public_dns_zone_id}"
  name = "${var.component}-${var.deployment_identifier}.${data.terraform_remote_state.common.domain_name}"
  type = "A"

  alias {
    name = "${aws_elb.load_balancer.dns_name}"
    zone_id = "${aws_elb.load_balancer.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "private" {
  zone_id = "${data.terraform_remote_state.common.private_dns_zone_id}"
  name = "${var.component}-${var.deployment_identifier}.${data.terraform_remote_state.common.domain_name}"
  type = "A"

  alias {
    name = "${aws_elb.load_balancer.dns_name}"
    zone_id = "${aws_elb.load_balancer.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_security_group" "load_balancer" {
  name = "elb-${var.component}-${var.deployment_identifier}"
  description = "ELB for component: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"
}

resource "aws_security_group_rule" "elb_egress" {
  type = "egress"

  from_port = 1
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = [
    "${data.aws_vpc.network.cidr_block}"
  ]

  security_group_id = "${aws_security_group.load_balancer.id}"
}

resource "aws_security_group_rule" "elb_peer_server_ingress" {
  type = "ingress"

  from_port = "${var.peer_server_port}"
  to_port = "${var.peer_server_port}"
  protocol = "TCP"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = "${aws_security_group.load_balancer.id}"
}

resource "aws_security_group_rule" "api_peer_server_ingress" {
  type = "ingress"

  from_port = "${var.api_server_port}"
  to_port = "${var.api_server_port}"
  protocol = "TCP"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = "${aws_security_group.load_balancer.id}"
}

resource "aws_elb" "load_balancer" {
  subnets = [
    "${split(",", data.terraform_remote_state.network.public_subnet_ids)}"
  ]
  security_groups = [
    "${aws_security_group.load_balancer.id}"
  ]

  internal = false


  listener {
    instance_port = "${var.peer_server_port}"
    instance_protocol = "TCP"
    lb_port = "${var.peer_server_port}"
    lb_protocol = "TCP"
  }

  listener {
    instance_port = "${var.api_server_port}"
    instance_protocol = "HTTP"
    lb_port = "${var.api_server_port}"
    lb_protocol = "HTTP"
  }

  health_check {
    target = "TCP:${var.peer_server_port}"
    timeout = 30
    interval = 60
    unhealthy_threshold = 10
    healthy_threshold = 10
  }

  tags {
    Name = "elb-${var.component}-${var.deployment_identifier}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}
