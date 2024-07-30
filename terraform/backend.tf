terraform {
  backend "s3" {
    bucket         = "marketvector-s3-bucket"
    key            = "terraform_statefile"   
    region         = "us-east-1"
    dynamodb_table = "marketvector-dynamodb" 
  }
}
