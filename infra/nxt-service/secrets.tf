data "template_file" "address" {
  template = "nxt-node-$${deployment_identifier}.$${domain_name}"

  vars {
    deployment_identifier = "${var.deployment_identifier}"
    domain_name = "${data.terraform_remote_state.common.domain_name}"
  }
}

data "template_file" "env" {
  template = "${file("${path.root}/envfiles/nxt.env.tpl")}"

  vars {
    initial_blockchain_archive_path = "${var.initial_blockchain_archive_path}"
    admin_password = "${var.admin_password}"
    key_store_password = "${var.key_store_password}"
    address = "${data.template_file.address.rendered}"
    api_server_port = "${var.api_server_port}"
  }
}

data "template_file" "env_key" {
  template = "secrets/environments/$${deployment_identifier}.env"

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