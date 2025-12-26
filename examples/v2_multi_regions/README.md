# Cloud Run Service using v2 API and multi-regions Example

This example showcases the basic deployment of containerized applications on Cloud Run and IAM policy for the service in multi-regions.

The resources/services/activations/deletions that this example will create/trigger are:

* Deploys a Cloud Run V2 service across multiple regions.
* Creates a Service Account to be used by Cloud Run Service.
* Creates a Serverless VPC Access Connectors per region.
* Cloud Run -> VPC integration through regional connectors.

## Assumptions and Prerequisites

This example assumes that below mentioned prerequisites are in place before consuming the example.

* All required APIs are enabled in the GCP Project

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_run\_deletion\_protection | Prevents Terraform from destroying/recreating Cloud Run jobs/services. | `bool` | `true` | no |
| cloud\_run\_vpc\_egress\_mode | Defines how Cloud Run connects to the VPC for outbound traffic. Modes can be default, direct-vpc-egress or vpc-access-connector. | `string` | `"default"` | no |
| image | Name of the image used by cloud run. | `string` | `"us-docker.pkg.dev/cloudrun/container/hello:latest"` | no |
| lb\_domain | Optional: Use an existing domain. Leave empty to use <IP>.sslip.io. | `string` | `null` | no |
| lb\_ip\_address | Optional: Use an existing Global IP for Load Balancer. Leave empty to create a new one. | `string` | `null` | no |
| location | Settings for creating a Multi-Region Service. Make sure to use region = 'global' if deploying a multi-region cloud run. | `string` | `"global"` | no |
| primary\_region | Primary region for reference. | `string` | `"us-west1"` | no |
| project\_id | Project where the Cloud Run v2 will be deployed. | `string` | n/a | yes |
| regions | Regions where serverless VPC Access connectors will be created. | `list(string)` | <pre>[<br>  "us-west1",<br>  "europe-west1"<br>]</pre> | no |
| service\_name | Cloud Run service name. | `string` | n/a | yes |
| vpc\_connectors | Configuration for Serverless VPC Access connectors by region. | <pre>map(object({<br>    name        = string<br>    region      = string<br>    subnet_name = string<br>  }))</pre> | `{}` | no |
| vpc\_egress\_traffic | Defines which outbound traffic from Cloud Run is routed through the VPC (private IP ranges only or all traffic) when VPC egress is enabled. | `string` | `"private-ranges-only"` | no |
| vpc\_network | Configuration of VPC Network by region (only for direct-vpc-egress). | `string` | `null` | no |
| vpc\_subnets | Configuration of VPC subnets by region (only for direct-vpc-egress). | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend\_service\_global | Global backend service backing the Cloud Run multi-region service. |
| cloud\_run\_regions | Regions where the Cloud Run service is deployed. |
| cloud\_run\_service\_account | Service account used by Cloud Run instances. |
| cloud\_run\_service\_id | Cloud Run service ID. |
| cloud\_run\_vpc\_egress\_mode | Cloud Run VPC egress mode in use. |
| cloud\_run\_vpc\_egress\_setting | Cloud Run VPC egress setting. |
| global\_entrypoint | Global HTTPS entrypoint for the Cloud Run multi-region service. |
| global\_forwarding\_rule\_id | ID of the global HTTPS forwarding rule. |
| https\_proxy\_id | ID of the HTTPS target proxy. |
| lb\_domain | Domain for the Load Balancer (IP.sslip.io if no custom domain is provided). |
| lb\_https\_url | HTTPS URL for the global Load Balancer. |
| lb\_ip | Global IP address of the Load Balancer. |
| serverless\_neg\_self\_links | Serverless NEG self links by region. |
| serverless\_negs | Serverless NEGs by region. |
| ssl\_certificate\_domains | Domains covered by the managed SSL certificate. |
| ssl\_certificate\_id | Managed SSL certificate ID. |
| url\_map\_id | ID of the URL map. |
| vpc\_connectors\_ids | VPC Access Connectors IDs by region. |
| vpc\_connectors\_names | VPC Access Connectors names by region. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this example.

### Software

* [Terraform](https://www.terraform.io/downloads.html) ~> v0.13+
* [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) ~> v5.0+
* [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) ~>
  v5.0+

### Service Account

A service account can be used with required roles to execute this example:

* Cloud Run Admin: `roles/run.admin`

Know more about [Cloud Run Deployment Permissions](https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration).

The [Project Factory module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest) and the
[IAM module](https://registry.terraform.io/modules/terraform-google-modules/iam/google/latest) may be used in combination to provision a service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the main resource of this example:

* Google Cloud Run: `run.googleapis.com`
* Google Compute Engine: `compute.googleapis.com`
* Google Servless VPC Acces: `vpcaccess.googleapis.com`
