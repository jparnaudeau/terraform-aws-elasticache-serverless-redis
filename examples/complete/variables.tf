variable "aws_region" {
  description = "The AWS Region"
  type        = string
}

variable "tags" {
  description = "a map of tags to put on resources"
  type        = map(string)
  default     = {}
}

variable "default_user" {
  description = "The default user infos"
  type        = any
}

variable "users" {
  description = "The list of redis users to create"
  type        = list(any)
  default     = []
}

variable "group" {
  description = "The redis group to create"
  type        = string
}