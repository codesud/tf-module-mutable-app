# Using this remote data source, we are fetching the outputs from remote state file. in this case VPC Statefile
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "b49-rf-remote-state-bucket"
    key    = "vpc/${var.ENV}/terraform.tfstate"
    region = "us-east-1"
  }
}


data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "b49-rf-remote-state-bucket"
    key    = "alb/${var.ENV}/terraform.tfstate"
    region = "us-east-1"
  }
}


data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "base-with-ansible"
  owners           = ["self"]
}


# fecthing the info of the secrets 
data "aws_secretsmanager_secret" "secrets" {
  name = "roboshop/secrets/all"
}

# Fetching the value of the secret string 
data "aws_secretsmanager_secret_version" "secrets" {
  secret_id     = data.aws_secretsmanager_secret.secrets.id
}


# printing the dataSource 
output "example" {
  value = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["DOCDB_USERNAME"]
}

# Added this for that so that we can fetch the MongoDB DNS Details
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "b49-tf-remote-state-bucket"
    key    = "databases/${var.ENV}/terraform.tfstate" 
    region = "us-east-1"
  }
}