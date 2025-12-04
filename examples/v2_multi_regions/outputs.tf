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

output "cloud_run_service_account" {
  description = "Service account used by Cloud Run instances."
  value       = google_service_account.sa.email
}

output "service_name" {
  description = "Service names per region."
  value = {
    for region, mod in module.cloud_run_v2_multiregion :
    region => mod.service_name
  }
}

output "service_uri" {
  description = "Service URIs per region."
  value = {
    for region, mod in module.cloud_run_v2_multiregion :
    region => mod.service_uri
  }
}

output "service_id" {
  description = "Service IDs per region."
  value = {
    for region, mod in module.cloud_run_v2_multiregion :
    region => mod.service_id
  }
}

output "vpc_connectors_ids" {
  description = "VPC Access Connectors IDs by region."
  value = {
    for region, connector in google_vpc_access_connector.vpc_connectors :
    region => connector.id
  }
  sensitive = false
}

output "vpc_connectors_names" {
  description = "VPC Access Connectors name by region."
  value = {
    for region, connector in google_vpc_access_connector.vpc_connectors :
    region => connector.name
  }
  sensitive = false
}
