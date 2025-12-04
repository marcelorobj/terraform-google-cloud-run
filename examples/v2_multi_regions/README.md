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
| project\_id | Project where the Cloud Run v2 will be deployed. | `string` | n/a | yes |
| regions | Regions where serverless vpc access connectors will be created. | `list(string)` | <pre>[<br>  "us-west1",<br>  "europe-west1"<br>]</pre> | no |
| vpc\_connectors | Configuration for Serverless VPC Access connectors by regions. | <pre>map(object({<br>    name        = string<br>    region      = string<br>    subnet_name = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_run\_service\_account | Service account used by Cloud Run instances. |
| service\_id | Service IDs per region |
| service\_name | Service names per region |
| service\_uri | Service URIs per region |
| vpc\_connectors\_ids | Serverless VPC Access Connectors IDs by region. |
| vpc\_connectors\_names | VPC Access Connectors. |

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
