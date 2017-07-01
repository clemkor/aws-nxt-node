module "ecr_repository" {
  source = "github.com/tobyclemson/terraform-aws-ecr-repository?ref=0.1.2//src"

  region = "${var.region}"
  repository_name = "eth-quest/nxt"
}
