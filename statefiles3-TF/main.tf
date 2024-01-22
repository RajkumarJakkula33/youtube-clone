resource "aws_s3_bucket" "terraform_state" {
  bucket = "eks-youtube-statefile-837"  
  # lifecycle {
  #   prevent_destroy = true  (prevent_destroy = true. This means that if someone tries to run terraform destroy, Terraform will prevent the destruction of s3bucket)
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.terraform_state]
  bucket = aws_s3_bucket.terraform_state.id
  acl = "private"  # or use "public-read" or "public-read-write" based on your requirements
  }

resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
}
resource "aws_dynamodb_table" "lock_table" {
  name           = "TFLOCK"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
