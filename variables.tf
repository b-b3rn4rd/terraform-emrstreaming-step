variable "cluster_id" {
  type = string
  description = "A unique string that identifies a cluster"
}

variable "step" {
  type = object({
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
  })

  description = "Specification for a cluster step"
}