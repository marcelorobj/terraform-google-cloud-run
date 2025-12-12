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

###########################################
# 1. Global IP
###########################################

resource "google_compute_global_address" "lb_ip" {
  count   = var.lb_ip_address == null ? 1 : 0
  name    = "cloudrun-global-ip"
  project = var.project_id
}

locals {
  lb_ip     = var.lb_ip_address != null ? var.lb_ip_address : google_compute_global_address.lb_ip[0].address
  lb_domain = var.lb_domain != null ? var.lb_domain : "${local.lb_ip}.sslip.io"
}

###########################################
# 2. Serverless NEGs
###########################################

resource "google_compute_region_network_endpoint_group" "cloudrun_negs" {
  for_each              = module.cloud_run_v2_multiregion
  project               = var.project_id
  region                = each.key
  name                  = "neg-cloudrun-${each.key}"
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = each.value.service_name
  }
}

###########################################
# 3. Backend Service Global
###########################################

resource "google_compute_backend_service" "cloudrun_backend_global" {
  project               = var.project_id
  name                  = "cloudrun-backend-global"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  enable_cdn            = false

  connection_draining_timeout_sec = 0

  outlier_detection {
    #Defines the number of consecutive errors a backend can have before being considered an “outlier” and potentially ejected.
    consecutive_errors = 1

    #Defines the maximum percentage of backend instances that can be ejected from a service.
    consecutive_gateway_failure = 1

    #Percentage of time that the consecutive_errors rule is enforced.
    enforcing_consecutive_errors          = 100
    enforcing_consecutive_gateway_failure = 100

    max_ejection_percent = 100

    interval {
      #The LB checks the backend state every 10 seconds.
      seconds = 1
    }

    base_ejection_time {
      #If us-west1 is ejected due to infrastructure errors, it will remain out of service for 300 seconds before the LB tries to send it traffic again.
      seconds = 300
    }
  }

  dynamic "backend" {
    for_each = google_compute_region_network_endpoint_group.cloudrun_negs
    content {
      group = backend.value.id
    }
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

###########################################
# 4. URL Map
###########################################

resource "google_compute_url_map" "cloudrun_urlmap" {
  name    = "cloudrun-urlmap"
  project = var.project_id

  default_service = google_compute_backend_service.cloudrun_backend_global.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.cloudrun_backend_global.id

    path_rule {
      paths = ["/*"]

      route_action {
        weighted_backend_services {
          backend_service = google_compute_backend_service.cloudrun_backend_global.id
          weight          = 100
        }

        retry_policy {
          #Specifies that the load balancer will retry the request up to 20 times if it fails under the conditions listed below.
          num_retries = 20

          per_try_timeout {
            #Each retry is allowed to run for a maximum of 10 seconds before being considered a failed attempt.
            seconds = 10
          }

          #Lists the types of errors that will trigger a retry.
          retry_conditions = [
            "5xx",
            "gateway-error",
            "connect-failure",
            "retriable-4xx",
            "gateway-timeout",
            "dead-deadline-exceeded",
            "503"
          ]
        }
      }
    }
  }
}

###########################################
# 5. Managed SSL Certificate
###########################################

resource "google_compute_managed_ssl_certificate" "cloudrun_cert" {
  name    = "cloudrun-cert"
  project = var.project_id

  managed {
    domains = [local.lb_domain]
  }
}

###########################################
# 6. HTTPS Proxy
###########################################

resource "google_compute_target_https_proxy" "cloudrun_https_proxy" {
  name             = "cloudrun-https-proxy"
  project          = var.project_id
  ssl_certificates = [google_compute_managed_ssl_certificate.cloudrun_cert.id]
  url_map          = google_compute_url_map.cloudrun_urlmap.id
}

###########################################
# 7. Forwarding Rule (HTTPS)
###########################################

resource "google_compute_global_forwarding_rule" "cloudrun_https_rule" {
  name                  = "cloudrun-https-rule"
  project               = var.project_id

  ip_address            = var.lb_ip_address != null ? var.lb_ip_address : google_compute_global_address.lb_ip[0].id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.cloudrun_https_proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"

  depends_on = [
    google_compute_target_https_proxy.cloudrun_https_proxy,
    google_compute_managed_ssl_certificate.cloudrun_cert
  ]
}
