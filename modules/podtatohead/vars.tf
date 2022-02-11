variable "podtato_version" {
  type = string
}

variable "hats_version" {
  type = string
}

variable "left_arm_version" {
  type = string
}

variable "right_arm_version" {
  type = string
}

variable "right_leg_version" {
  type = string
}

variable "left_leg_version" {
  type = string
}
variable "podtato_name" {
    type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "min_instances" {
  type = number
  default = 1
}

variable "max_instances" {
  type = number
  default = 1
}

variable "desired_instances" {
  type = number
  default = 1
}

variable "VarDdApiKey" {
  type = string
}

variable "VarDdImage" {
  type = string
}

variable "gitHubUser" {
  type = string
}

variable "gitHubClientId" {
  type = string
}

variable "gitHubClientSecret" {
  type = string
}
