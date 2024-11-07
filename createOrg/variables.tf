variable "vcd_url" {
  type = string
  description = "The URL of the vCD instance"
  default = "<%=customOptions.vCD_url%>"
}

variable "vcd_username" {
  type = string
  description = "The username for the vCD instance"
  default = "<%=customOptions.vCD_user%>"
}

variable "vcd_password" {
  type = string
  description = "The password for the vCD instance"
  sensitive   = true
  default = "<%=customOptions.vCD_pass%>"
}

variable "orgname" {
  type = string
  description = "accept org name from catalog"
  default = "<%=customOptions.vCD_org%>"
}

variable "vdc_name" {
  type = string
  description = "<%=customOptions.vDC_name%>"
}