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

variable "vdc_name" {
  type = string
  description = "vDC name passed from the service catalog"
}

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

variable "org_name" {
  description = "Name of the organization passed from service catalog"
  type        = string
}

variable "org_full_name" {
  description = "Full name of the organization passed from service catalog"
  type        = string
}

variable "org_description" {
  description = "Description of the organization passed from service catalog"
  type        = string
}