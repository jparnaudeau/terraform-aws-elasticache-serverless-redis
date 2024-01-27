#######################################
# Tags Variables
#######################################
variable "tags" {
  type        = map(string)
  description = "A list of tags to put on resources"
}


#######################################
# Default Redis User Variables
#######################################
variable "default_user" {
  description = "The default user referenced into the redis group"
  type = object({
    user_id             = string
    user_name           = string
    access_string       = string
    secret_description  = string
    secret_name         = string
    authentication_mode = string
  })
}


#######################################
# Redis Users Variables
#######################################
variable "users" {
  description = "The List of Users to create inside the Elasticache Redis Cluster"
  type = list(object({
    user_id             = string
    user_name           = string
    access_string       = string
    secret_description  = string
    secret_name         = string
    authentication_mode = string
  }))
  default = []
}

variable "kms_key_arn" {
  description = "The KMS Key Arn to use for encrpyting the password of redis users"
  type        = string
}

#######################################
# Redis Group Variables
#######################################
variable "group" {
  description = "The Group to create and to associate to the redis serverless cluster"
  type        = string
}