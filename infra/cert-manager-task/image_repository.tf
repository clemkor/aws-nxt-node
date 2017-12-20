data "terraform_remote_state" "image_repository" {
  backend = "s3"

  config {
    bucket = "${var.image_repository_state_bucket_name}"
    key = "${var.image_repository_state_key}"
    region = "${var.region}"
    encrypt = "true"
  }
}