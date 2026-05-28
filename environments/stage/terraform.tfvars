environment = "stage"

domain_name     = "cloudforsushant.xyz"
api_domain_name = "api.cloudforsushant.xyz"
email_endpoint  = "cloudforsushant77@gmail.com"

# Your existing ACM certificate ARN (must be in us-east-1)
acm_certificate_arn = "arn:aws:acm:us-east-1:926827028763:certificate/6918e865-9fbe-4d6a-93a5-fd2e5b6eb70e"

# Your existing Route53 zone ID
zone_id = "Z06508003RB90DEZWS011"

tags = {
  Environment = "dev"
  Project     = "ServerlessCore"
  ManagedBy   = "terraform"
}

waf_rate_limit = 10
