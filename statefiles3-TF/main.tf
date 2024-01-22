resource "aws_s3_bucket" "terraform_state" {
  bucket = "eks-youtube-statefile-837"
  acl    = "private"     
  lifecycle {
    prevent_destroy = true
  }
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
