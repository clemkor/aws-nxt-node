data "terraform_remote_state" "image_repository" {
  backend = "s3"

  config {
    bucket = "${var.state_bucket}"
    key = "${var.image_repository_state_key}"
    region = "${var.region}"
  }
}