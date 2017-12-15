module "encrypted_bucket" {
  source = "github.com/infrablocks/terraform-aws-encrypted-bucket?ref=0.1.2//src"

  region = "${var.region}"
  bucket_name = "${var.blockchain_archive_bucket_name}"
}