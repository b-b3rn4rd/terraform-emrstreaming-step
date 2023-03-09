resource "emrstreaming_step" "step" {
  cluster_id = var.cluster_id
  step = var.step
}