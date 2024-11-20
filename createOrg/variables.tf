variable "vcd_url" {
  type = string
  description = "The URL of the vCD instance"
}

variable "vcd_username" {
  type = string
  description = "The username for the vCD instance"
}

variable "vcd_password" {
  type = string
  description = "The password for the vCD instance"
  sensitive   = true
}

# variable "orgname" {
#   type = string
#   description = "accept org name from catalog"
# }

# variable "vdc_name" {
#   type = string
#   description = "<%=customOptions.vDC_name%>"
# }

variable "provider_vdc_name" {
  description = "Name of the provider VDC"
  type        = string
}

variable "network_pool_name" {
  description = "Name of the network pool"
  type        = string
}

variable "storage_profile_name" {
  description = "Name of the storage profile"
  type        = string
}