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

###############################################################################
# CLOUD RUN
###############################################################################

output "cloud_run_service_account" {
  description = "Service account used by Cloud Run instances."
  value       = google_service_account.sa.email
}

# output "service_name" {
#   description = "Cloud Run service name (multi-region)."
#   value       = module.cloud_run_v2_multiregion.service_name
# }

# output "service_uri" {
#   description = "Cloud Run service URI (multi-region)."
#   value       = module.cloud_run_v2_multiregion.service_uri
# }

# output "service_id" {
#   description = "Cloud Run service ID (multi-region)."
#   value       = module.cloud_run_v2_multiregion.service_id
# }

output "cloud_run_regions" {
  description = "Regions where the Cloud Run service is deployed."
  value       = var.regions
}

output "cloud_run_service_name" {
  description = "Cloud Run service name."
  value       = var.service_name
}

output "backend_service_name" {
  description = "Global backend service name."
  value       = google_compute_backend_service.cloudrun_backend_global.name
}

output "serverless_negs" {
  description = "Serverless NEGs by region."
  value = {
    for region, neg in google_compute_region_network_endpoint_group.cloudrun_neg :
    region => neg.name
  }
}

output "url_map_name" {
  description = "URL map name."
  value       = google_compute_url_map.cloudrun_urlmap.name
}

output "https_proxy_name" {
  description = "HTTPS proxy name."
  value       = google_compute_target_https_proxy.cloudrun_https_proxy.name
}

output "https_forwarding_rule_name" {
  description = "HTTPS forwarding rule name."
  value       = google_compute_global_forwarding_rule.cloudrun_https_rule.name
}


###############################################################################
# VPC ACCESS CONNECTORS
###############################################################################

output "vpc_connectors_ids" {
  description = "VPC Access Connectors IDs by region."
  value = {
    for region, connector in google_vpc_access_connector.vpc_connectors :
    region => connector.id
  }
}

output "vpc_connectors_names" {
  description = "VPC Access Connectors names by region."
  value = {
    for region, connector in google_vpc_access_connector.vpc_connectors :
    region => connector.name
  }
}

###############################################################################
# LOAD BALANCER / NETWORKING
###############################################################################

# output "serverless_neg_id" {
#   description = "Serverless Network Endpoint Group ID used by the global load balancer."
#   value       = google_compute_region_network_endpoint_group.cloudrun_neg.id
# }

output "backend_service_global" {
  description = "Global backend service backing the Cloud Run multi-region service."
  value       = google_compute_backend_service.cloudrun_backend_global.id
}

output "lb_ip" {
  description = "Global IP address of the Load Balancer."
  value       = local.lb_ip
}

output "lb_domain" {
  description = "Domain for the Load Balancer (IP.sslip.io if no custom domain is provided)."
  value       = local.lb_domain
}

output "lb_https_url" {
  description = "HTTPS URL for the global Load Balancer."
  value       = "https://${local.lb_domain}"
}

output "ssl_certificate_id" {
  description = "Managed SSL certificate ID."
  value       = google_compute_managed_ssl_certificate.cloudrun_cert.id
}

output "global_entrypoint" {
  description = "Global HTTPS entrypoint for the Cloud Run multi-region service."
  value       = "https://${local.lb_domain}"
}

