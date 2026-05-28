terraform {
  backend "s3" {
    bucket = "serverlesscore-tfstate-926827028763"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
