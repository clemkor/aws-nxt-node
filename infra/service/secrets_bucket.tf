data "terraform_remote_state" "secrets_bucket" {
  backend = "s3"

  config {
    bucket = "${var.state_bucket}"
    key = "${var.secrets_bucket_state_key}"
    region = "${var.region}"
  }
}