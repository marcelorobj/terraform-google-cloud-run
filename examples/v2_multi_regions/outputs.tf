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

output "cloud_run_service_id" {
  description = "Cloud Run service ID."
  value       = module.cloud_run_v2_multiregion.service_id
}

output "global_forwarding_rule_id" {
  description = "ID of the global HTTPS forwarding rule."
  value       = google_compute_global_forwarding_rule.cloudrun_https_rule.id
}

output "https_proxy_id" {
  description = "ID of the HTTPS target proxy."
  value       = google_compute_target_https_proxy.cloudrun_https_proxy.id
}

output "url_map_id" {
  description = "ID of the URL map."
  value       = google_compute_url_map.cloudrun_urlmap.id
}

output "serverless_neg_self_links" {
  description = "Serverless NEG self links by region."
  value = {
    for region, neg in google_compute_region_network_endpoint_group.cloudrun_neg :
    region => neg.self_link
  }
}

output "ssl_certificate_domains" {
  description = "Domains covered by the managed SSL certificate."
  value       = google_compute_managed_ssl_certificate.cloudrun_cert.managed[0].domains
}

output "cloud_run_vpc_egress_mode" {
  description = "Cloud Run VPC egress mode in use."
  value       = var.cloud_run_vpc_egress_mode
}

output "cloud_run_vpc_egress_setting" {
  description = "Cloud Run VPC egress setting."
  value       = var.vpc_egress_traffic
}

output "cloud_run_regions" {
  description = "Regions where the Cloud Run service is deployed."
  value       = var.regions
}

output "serverless_negs" {
  description = "Serverless NEGs by region."
  value = {
    for region, neg in google_compute_region_network_endpoint_group.cloudrun_neg :
    region => neg.name
  }
}

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
