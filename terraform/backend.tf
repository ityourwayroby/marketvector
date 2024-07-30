terraform {
  backend "s3" {
    bucket         = "marketvector-s3-bucket-1"
    key            = "terraform_statefile"   
    region         = "us-east-1"
    dynamodb_table = "new-dynamodb" 
  }
}
