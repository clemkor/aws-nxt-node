data "template_file" "env" {
  template = "${file("${path.root}/envfiles/nxt.env.tpl")}"

  vars {
    initial_blockchain_archive_path = "${var.initial_blockchain_archive_path}"
    admin_password = "${var.admin_password}"
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