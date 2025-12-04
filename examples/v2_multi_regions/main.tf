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
  vpc_connectors_ids = {
    for region, conn in google_vpc_access_connector.vpc_connectors :
    region => conn.id
  }

  vpc_config_valid = (
    (var.vpc_mode == "vpc-access-connector" && length(var.vpc_connectors) > 0) ||
    (var.vpc_mode == "direct-vpc-egress" && var.vpc_network != null && length(var.vpc_subnets) > 0)
  )
}

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = "ci-cloud-run-v2-sa"
  display_name = "Service account for ci-cloud-run-v2-sa"
}

resource "google_vpc_access_connector" "vpc_connectors" {
  for_each = var.vpc_mode == "vpc-access-connector" ? var.vpc_connectors : {}

  name    = each.value.name
  project = var.project_id
  region  = each.value.region

  subnet {
    name = each.value.subnet_name
  }

  min_instances = 2
  max_instances = 4
}

resource "null_resource" "validate_vpc" {
  count = local.vpc_config_valid ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'ERROR: VPC configuration invalid. Check your vpc_mode, vpc_connectors, vpc_network and vpc_subnets'' && exit 1"
  }
}

module "cloud_run_v2_multiregion" {
  source = "../../modules/v2"

  for_each = toset(var.regions)

  service_name = "cloudrun-multiregion-${each.key}"
  project_id   = var.project_id
  location     = each.key

  create_service_account = false
  service_account        = google_service_account.sa.email

  cloud_run_deletion_protection = var.cloud_run_deletion_protection

  vpc_access = (
    var.vpc_mode == "vpc-access-connector"
    ?
    {
      connector          = local.vpc_connectors_ids[each.key]
      egress             = "PRIVATE_RANGES_ONLY"
      network_interfaces = null
    }
    :
    {
      connector = null
      egress    = var.vpc_egress
      network_interfaces = {
        network    = var.vpc_network
        subnetwork = var.vpc_subnets[each.key]
      }
    }
  )

  containers = [
    {
      container_image = "us-docker.pkg.dev/cloudrun/container/hello"
      container_name  = "hello-world"
    }
  ]
}
