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

variable "location" {
  type        = string
  description = " Settings for creating a Multi-Region Service. Make sure to use region = 'global' if deploying a multi-region cloud run."
  default     = "global"
}

variable "service_name" {
  type        = string
  description = "Cloud Run service name."
}

variable "image" {
  type        = string
  description = "Name of the image used by cloud run."
  default     = "us-docker.pkg.dev/cloudrun/container/hello:latest"
}

variable "cloud_run_deletion_protection" {
  type        = bool
  description = "Prevents Terraform from destroying/recreating Cloud Run jobs/services."
  default     = true
}

variable "cloud_run_vpc_egress_mode" {
  type        = string
  description = "Defines how Cloud Run connects to the VPC for outbound traffic. Modes can be default, direct-vpc-egress or vpc-access-connector."
  default     = "default"

  validation {
    condition = contains(
      ["default", "direct-vpc-egress", "vpc-access-connector"],
      var.cloud_run_vpc_egress_mode
    )
    error_message = "cloud_run_vpc_egress_mode must be 'default', 'direct-vpc-egress' or 'vpc-access-connector'."
  }
}

variable "vpc_connectors" {
  type = map(object({
    name        = string
    region      = string
    subnet_name = string
  }))
  description = "Configuration for Serverless VPC Access connectors by region."
  default     = {}
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

variable "vpc_egress_traffic" {
  type        = string
  description = "Defines which outbound traffic from Cloud Run is routed through the VPC (private IP ranges only or all traffic) when VPC egress is enabled."
  default     = "private-ranges-only"
  validation {
    condition     = var.vpc_egress_traffic == null || can(regex("^(private-ranges-only|all-traffic)$", var.vpc_egress_traffic))
    error_message = "vpc_egress_traffic must be private-ranges-only, all-traffic or null."
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

variable "enable_load_balancer" {
  type        = bool
  description = "If true, creates the Global Load Balancer resources. Defaults to false."
  default     = false
}
