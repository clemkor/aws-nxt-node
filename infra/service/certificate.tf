data "aws_acm_certificate" "wildcard" {
  domain = "*.${data.terraform_remote_state.common.domain_name}"
  statuses = ["ISSUED"]
}
