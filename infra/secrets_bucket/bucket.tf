module "encrypted_bucket" {
  source = "github.com/infrablocks/terraform-aws-encrypted-bucket?ref=0.1.3//src"

  region = "${var.region}"
  bucket_name = "${var.bucket_name}"
}