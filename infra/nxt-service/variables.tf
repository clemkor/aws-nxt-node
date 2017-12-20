variable "region" {}

variable "component" {}
variable "deployment_identifier" {}
variable "service_name" {}

variable "version_number" {}

variable "admin_password" {}
variable "key_store_password" {}

variable "peer_server_port" {}
variable "api_server_port" {}

variable "initial_blockchain_archive_path" {}

variable "desired_count" {}
variable "deployment_maximum_percent" {}
variable "deployment_minimum_healthy_percent" {}

variable "secrets_bucket_name" {}

variable "common_state_bucket_name" {}
variable "common_state_key" {}

variable "network_state_bucket_name" {}
variable "network_state_key" {}

variable "cluster_state_bucket_name" {}
variable "cluster_state_key" {}

variable "image_repository_state_bucket_name" {}
variable "image_repository_state_key" {}