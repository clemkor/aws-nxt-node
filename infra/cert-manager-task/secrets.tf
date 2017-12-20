data "template_file" "domain" {
  template = "nxt-node-$${deployment_identifier}.$${domain_name}"

  vars {
    deployment_identifier = "${var.deployment_identifier}"
    domain_name = "${data.terraform_remote_state.common.domain_name}"
  }
}

data "template_file" "email" {
  template = "$${user}@$${domain_name}"

  vars {
    user = "admin"
    domain_name = "${data.terraform_remote_state.common.domain_name}"
  }
}

data "template_file" "env" {
  template = "${file("${path.root}/envfiles/cert-manager.env.tpl")}"

  vars {
    domain = "${data.template_file.domain.rendered}"
    email = "${data.template_file.email.rendered}"
    hosted_zone_id = "${data.terraform_remote_state.common.public_dns_zone_id}"
    key_store_password = "${var.key_store_password}"
  }
}

data "template_file" "env_key" {
  template = "secrets/cert-manager/environments/$${deployment_identifier}.env"

  vars {
    deployment_identifier = "${var.deployment_identifier}"
  }
}

data "template_file" "env_url" {
  template = "s3://$${bucket_name}/$${key}"

  vars {
    bucket_name = "${var.secrets_bucket_name}"
    key = "${data.template_file.env_key.rendered}"
  }
}

resource "aws_s3_bucket_object" "env" {
  key = "${data.template_file.env_key.rendered}"
  bucket = "${var.secrets_bucket_name}"
  content = "${data.template_file.env.rendered}"

  server_side_encryption = "AES256"
}