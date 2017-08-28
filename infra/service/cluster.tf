data "terraform_remote_state" "cluster" {
  backend = "s3"

  config {
    bucket = "${var.state_bucket}"
    key = "${var.cluster_state_key}"
    region = "${var.region}"
  }
}