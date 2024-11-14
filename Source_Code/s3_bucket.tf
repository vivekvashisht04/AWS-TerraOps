# S3 bucket for storing Terraform state

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket  # Use variable for Terraform state bucket name

  tags = {
    Name        = "TerraformStateBucket"
    Environment = "Dev"
  }
}

# Public access block for the S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy      = true
  restrict_public_buckets  = true
  ignore_public_acls       = true
}

# S3 bucket for backups

resource "aws_s3_bucket" "backup_bucket" {
  bucket = var.backup_bucket  # Use variable for backup bucket name

  tags = {
    Name        = "BackupBucket"
    Environment = "Dev"
  }
}

# Public access block for the backup S3 bucket
resource "aws_s3_bucket_public_access_block" "backup_bucket_block" {
  bucket = aws_s3_bucket.backup_bucket.id

  block_public_acls       = true
  block_public_policy      = true
  restrict_public_buckets  = true
  ignore_public_acls       = true
}