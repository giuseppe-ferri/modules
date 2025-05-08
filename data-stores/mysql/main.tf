terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true

  # Enable backups
  backup_retention_period = var.backup_retention_period

  # If specified, this DB will be a replica
  replicate_source_db = var.replicate_source_db

  # Only set these param if replicate_source_db is not set
  engine   = var.replicate_source_db == null ? "mysql" : null
  db_name  = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? var.db_password : null
}

# terraform {
#   backend "s3" {
#     # Replace this with your bucket name!
#     bucket = "unique-name-bucket-jiow02"
#     key    = "stage/data-stores/mysql/terraform.tfstate"
#     region = "us-east-2"

#     # Replace this with your DynamoDB table name!
#     dynamodb_table = "unique-name-dynamo-jiow02"
#     encrypt        = true
#   }
# }