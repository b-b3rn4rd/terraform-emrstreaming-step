variable "cluster_id" {
  type = string
  description = "A unique string that identifies a cluster"
}

variable "steps" {
    type = map(object({
    name = string
    force_redeploy = optional(bool)
    health_check_monitor_period=number
    pre_shutdown_wait_period=number
    shutdown_timeout=number
    hadoop_jar_step = object({
        args = optional(list(string))
        jar = string
        main_class = optional(string)
        properties = optional(map(string))
        })
    }))
    default = {
      "example-app" = {
        hadoop_jar_step = {
          args = [
              "spark-submit",
              "--name", "example-app",
              "--deploy-mode", "cluster",
              "--master", "yarn",
              "--conf", "spark.dynamicAllocation.enabled=true",
              "s3://_S3_BUCKET_NAME_/example-app/main.py"
          ]
          jar = "command-runner.jar"
        }
        health_check_monitor_period = 120
        name                        = "example-app"
        force_redeploy              = true
        pre_shutdown_wait_period    = 10
        shutdown_timeout            = 60
      }
    }
  description = "Specifications for a cluster steps"
}