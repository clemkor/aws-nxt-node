variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "version_number" {}

variable "peer_server_port" {}
variable "ui_server_port" {}
variable "api_server_port" {}

variable "desired_count" {}
variable "deployment_maximum_percent" {}
variable "deployment_minimum_healthy_percent" {}

variable "state_bucket" {}
variable "common_state_key" {}
variable "network_state_key" {}
variable "cluster_state_key" {}
variable "image_repository_state_key" {}
variable "secrets_bucket_state_key" {}
