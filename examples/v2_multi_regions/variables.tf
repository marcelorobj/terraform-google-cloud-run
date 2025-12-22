/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  type        = string
  description = "Project where the Cloud Run v2 will be deployed."
}

variable "regions" {
  type        = list(string)
  description = "Regions where serverless VPC Access connectors will be created."
  default     = ["us-west1", "europe-west1"]
}

variable "service_name" {
  type    = string
  default = "cloudrun-multiregion"
}

variable "image" {
  type    = string
  default = "us-docker.pkg.dev/cloudrun/container/hello:latest"
}

variable "cloud_run_deletion_protection" {
  type        = bool
  description = "Prevents Terraform from destroying/recreating Cloud Run jobs/services."
  default     = true
}

variable "vpc_mode" {
  type        = string
  description = "VPC Mode: default, direct-vpc-egress or vpc-access-connector."
  default     = "default"

  validation {
    condition = contains(
      ["default", "direct-vpc-egress", "vpc-access-connector"],
      var.vpc_mode
    )
    error_message = "vpc_mode must be 'default', 'direct-vpc-egress' or 'vpc-access-connector'."
  }
}

variable "vpc_connectors" {
  description = "Configuration for Serverless VPC Access connectors by region."
  type = map(object({
    name        = string
    region      = string
    subnet_name = string
  }))
  default = {}
}

variable "vpc_network" {
  type        = string
  description = "Configuration of VPC Network by region (only for direct-vpc-egress)."
  default     = null
}

variable "vpc_subnets" {
  type        = map(string)
  description = "Configuration of VPC subnets by region (only for direct-vpc-egress)."
  default     = {}
}

variable "vpc_egress" {
  type    = string
  default = "private-ranges-only"
  validation {
    condition     = var.vpc_egress == null || can(regex("^(private-ranges-only|all-traffic)$", var.vpc_egress))
    error_message = "vpc_egress must be private-ranges-only, all-traffic or null."
  }
}

variable "primary_region" {
  type        = string
  description = "Primary region for reference."
  default     = "us-west1"
}

variable "lb_ip_address" {
  type        = string
  description = "Optional: Use an existing Global IP for Load Balancer. Leave empty to create a new one."
  default     = null
}

variable "lb_domain" {
  type        = string
  description = "Optional: Use an existing domain. Leave empty to use <IP>.sslip.io."
  default     = null
}
