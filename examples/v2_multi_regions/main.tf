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

locals {
  vpc_flags = (
    var.cloud_run_vpc_egress_mode == "vpc-access-connector" ?
    "--vpc-connector=${var.vpc_connectors[var.primary_region].name} --vpc-egress=${var.vpc_egress_traffic}" :
    var.cloud_run_vpc_egress_mode == "direct-vpc-egress" ?
    "--network=${var.vpc_network} --subnet=${var.vpc_subnets[var.primary_region]} --vpc-egress=${var.vpc_egress_traffic}" :
    ""
  )
}

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = "ci-cloud-run-v2-sa"
  display_name = "Service account for Cloud Run multi-region"
}

resource "google_vpc_access_connector" "vpc_connectors" {
  for_each = var.cloud_run_vpc_egress_mode == "vpc-access-connector" ? var.vpc_connectors : {}

  name    = each.value.name
  project = var.project_id
  region  = each.value.region

  subnet {
    name = each.value.subnet_name
  }

  min_instances = 2
  max_instances = 4
}

resource "null_resource" "validate_primary_region" {
  count = contains(var.regions, var.primary_region) ? 0 : 1

  provisioner "local-exec" {
    command = "echo \"ERROR: primary_region (${var.primary_region}) must be one of: ${join(", ", var.regions)}\" && exit 1"
  }
}

resource "null_resource" "validate_vpc" {
  count = (
    var.cloud_run_vpc_egress_mode != "default" && (
      (var.cloud_run_vpc_egress_mode == "vpc-access-connector" && length(var.vpc_connectors) == 0) ||
      (var.cloud_run_vpc_egress_mode == "direct-vpc-egress" &&
        (var.vpc_network == null || length(var.vpc_subnets) == 0)
      )
    )
  ) ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: Invalid VPC configuration for selected cloud_run_vpc_egress_mode' && exit 1"
  }
}

module "cloud_run_v2_multiregion" {
  source = "../../modules/v2"

  service_name                  = var.service_name
  location                      = var.location
  project_id                    = var.project_id
  create_service_account        = false
  service_account               = google_service_account.sa.email
  cloud_run_deletion_protection = var.cloud_run_deletion_protection

  multi_region_settings = {
    regions = var.regions
  }

  load_balancer_config = var.enable_load_balancer ? {
    regions           = var.regions
    global_ip_address = var.lb_ip_address
    domain            = var.lb_domain
    name_prefix       = var.service_name
  } : null

  containers = [
    {
      container_image = var.image
      container_name  = "hello-world"

      startup_probe = {
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3
        failure_threshold     = 5

        http_get = {
          path = "/"
          port = 8080
        }
      }

      liveness_probe = {
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3
        failure_threshold     = 5

        http_get = {
          path = "/"
          port = 8080
        }
      }
    }
  ]
}
