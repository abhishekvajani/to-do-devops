terraform {
  backend "s3" {
    bucket         = "devopspr"               # S3 bucket name
    key            = "terraformstate/terraform.tfstate"      # Path in the bucket where the state file will be stored
    region         = "us-west-2"                       # AWS region where the bucket is located
    encrypt        = true                               # Enable server-side encryption
    dynamodb_table = "devops"       # Name of the DynamoDB table for state locking
  }
}