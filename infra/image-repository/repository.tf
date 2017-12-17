module "repository" {
  source = "github.com/infrablocks/terraform-aws-ecr-repository?ref=0.1.6//src"

  region = "${var.region}"
  repository_name = "eth-quest/${var.image_name}"
}
