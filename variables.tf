
variable "region" {
  default     = "UK West"
  description = "Region to deploy the cluster to"
  type        = string
}

variable "name" {
  default     = "demo"
  description = "Base Name for resources"
  type        = string
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}