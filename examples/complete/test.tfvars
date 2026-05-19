region         = "us-east-2"
name_prefix    = "vpce-test"
vpc_cidr_block = "10.48.0.0/16"
subnet_cidr_a  = "10.48.10.0/24"
subnet_cidr_b  = "10.48.11.0/24"

tags = {
  Environment = "test"
  Owner       = "terratest"
  Service     = "vpc-endpoint"
}
