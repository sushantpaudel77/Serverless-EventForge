terraform {
  backend "s3" {
    bucket = "prod-terraform-state-cloudforsushant"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}