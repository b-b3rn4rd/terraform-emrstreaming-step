# terraform-emrstreaming-step
Terraform module to deploy streaming steps on an EMR cluster
## Example
```hcl
provider "emrstreaming" {
  region = "ap-southeast-2"
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "emrstreaming_s3_bucket" {
  bucket_prefix = "emrstreaming-test"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "emrstreaming_s3_bucket" {
  bucket = aws_s3_bucket.emrstreaming_s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_object" "emrstreaming_step_source" {
  for_each = var.steps

  key    = "${each.key}/main.py"
  bucket = aws_s3_bucket.emrstreaming_s3_bucket.id
  source = "${each.key}/main.py"
  force_destroy = true
  server_side_encryption = "AES256"
  etag = filemd5("${each.key}/main.py")
}

module "emrstreaming_step" {
  depends_on = [
    aws_s3_object.emrstreaming_step_source
  ]
  source = "b-b3rn4rd/terraform-emrstreaming-step"
  for_each = var.steps
  cluster_id = var.cluster_id
  // a hacky way of replacing the bucket name in the step config, in the real world you will probabyl use hardcoded bucket names
  // as job files will be already uploaded to s3
  step = jsondecode(replace(jsonencode(each.value), "_S3_BUCKET_NAME_", aws_s3_bucket.emrstreaming_s3_bucket.id))
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_emrstreaming"></a> [emrstreaming](#requirement\_emrstreaming) | >= 0.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_emrstreaming"></a> [emrstreaming](#provider\_emrstreaming) | >= 0.0.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [emrstreaming_step.step](https://registry.terraform.io/providers/b-b3rn4rd/emrstreaming/latest/docs/resources/step) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | A unique string that identifies a cluster | `string` | n/a | yes |
| <a name="input_step"></a> [step](#input\_step) | Specification for a cluster step | <pre>object({<br>    name = string<br>    force_redeploy = optional(bool)<br>    health_check_monitor_period=number<br>    pre_shutdown_wait_period=number<br>    shutdown_timeout=number<br>    hadoop_jar_step = object({<br>        args = optional(list(string))<br>        jar = string<br>        main_class = optional(string)<br>        properties = optional(map(string))<br>    })<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->