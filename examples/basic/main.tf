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
  source = "../../"
  for_each = var.steps
  cluster_id = var.cluster_id
  // a hacky way of replacing the bucket name in the step config, in the real world you will probabyl use hardcoded bucket names
  // as job files will be already uploaded to s3
  step = jsondecode(replace(jsonencode(each.value), "_S3_BUCKET_NAME_", aws_s3_bucket.emrstreaming_s3_bucket.id))
}