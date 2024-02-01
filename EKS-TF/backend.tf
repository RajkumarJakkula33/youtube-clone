terraform {
  backend "s3" {
    bucket         = "eks-youtube-statefile-837"
    key            = "backend/EKS.tfstate"
    region         = "us-east-1"
    # encrypt        = true
    # dynamodb_table = "your-lock-table"
}
}
