provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-up-and-running-state"

    # prevent accidental deletion of this bucket 
    lifecycle {
        prevent_destroy = true
    }
}

#enable versioning of state files

resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

# enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# explicitly block all public access
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform_up_and_running_locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}