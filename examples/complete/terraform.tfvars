# define provider's region
aws_region = "eu-west-1"

# tags
tags = {
  Application = "myapp"
  Environment = "dev"
}

# define default user
default_user = {
  user_id             = "default-myapp-user"
  user_name           = "default"
  access_string       = "on ~acme::* -@all +@read +@write +cluster|nodes +@connection"
  group               = "myredis-group"
  secret_description  = "The Secret containing credentials for the %s on Elasticache Redis Serverless Cluster" # %s will be replace by the user_id value
  secret_name         = "/dev/myapp/redis/%s"                                                                  # %s will be replace by the user_id value
  authentication_mode = "password"
}

# define the list of users to create
users = [
  {
    user_id             = "web-dev-redis"
    user_name           = "web-dev-redis"
    access_string       = "on ~myapp::* -@all +@read +cluster|nodes"
    secret_description  = "Credentials for the user %s on Elasticache Redis Serverless Cluster" # keep one %s. It will be replace by the user_id value
    secret_name         = "/dev/myapp/redis/%s"                                                 # keep one %s. # It will be replace by the user_id value
    authentication_mode = "iam"
  },
  {
    user_id             = "app-dev-redis"
    user_name           = "app-dev-redis"
    access_string       = "on ~myapp::* -@all +@read +@write +cluster|nodes +@connection"
    secret_description  = "Credentials for the user %s on Elasticache Redis Serverless Cluster"
    secret_name         = "/dev/myapp/redis/%s"
    authentication_mode = "password"
  },
]

# define the group 
group = "dev-myapp-redis-group"

