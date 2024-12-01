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
