terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    emrstreaming = {
      source = "b-b3rn4rd/emrstreaming"
      version = ">= 0.0.1"
    }
  }
}
