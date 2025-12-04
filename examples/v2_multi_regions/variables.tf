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
  description = "Regions where serverless vpc access connectors will be created."
  default     = ["us-west1", "europe-west1"]
}

variable "cloud_run_deletion_protection" {
  type        = bool
  description = "Prevents Terraform from destroying/recreating Cloud Run jobs/services."
  default     = true
}

variable "vpc_mode" {
  type        = string
  description = "VPC Mode: direct-vpc-egress (default) or vpc-access-connector."
  default     = "direct-vpc-egress"

  validation {
    condition     = contains(["direct-vpc-egress", "vpc-access-connector"], var.vpc_mode)
    error_message = "vpc_mode must be 'direct-vpc-egress' or 'vpc-access-connector'."
  }
}

variable "vpc_connectors" {
  description = "Configuration for Serverless VPC Access connectors by regions."
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
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
  validation {
    condition     = var.vpc_egress == null || can(regex("^(PRIVATE_RANGES_ONLY|ALL_TRAFFIC)$", var.vpc_egress))
    error_message = "vpc_egress must be PRIVATE_RANGES_ONLY, ALL_TRAFFIC or null."
  }
}
