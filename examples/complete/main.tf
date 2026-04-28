// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

# This example demonstrates a complete Interface-type VPC endpoint for the S3
# service, including all supporting networking resources. It is designed to be
# used as the Terratest fixture for post-deploy functional testing.
#
# Architecture:
#   VPC (10.48.0.0/16)
#   ├── subnet-a (10.48.10.0/24, AZ a)  ─┐
#   └── subnet-b (10.48.11.0/24, AZ b)  ─┴── VPC Endpoint (Interface, S3)
#                                              └── Security Group (HTTPS ingress from VPC)
# ---------------------------------------------------------------------------
# Networking foundation
# ---------------------------------------------------------------------------

# VPC with DNS support and hostnames enabled — both are required for Interface
# endpoint private DNS to function correctly.
module "vpc" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/vpc/aws"
  version = "~> 1.0.5"

  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

# Lock down the default security group so no implicit rules are inherited by
# resources that do not explicitly reference a security group.
resource "aws_default_security_group" "vpc" {
  vpc_id  = module.vpc.vpc_id
  ingress = []
  egress  = []

  tags = merge(var.tags, { Name = "${var.name_prefix}-default-sg" })
}

# ---------------------------------------------------------------------------
# Private subnets
# One subnet per AZ provides multi-AZ resiliency for the endpoint ENIs.
# ---------------------------------------------------------------------------

module "subnet_a" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/subnet/aws"
  version = "~> 1.0.5"

  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.subnet_cidr_a
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name_prefix}-subnet-a" })
}

module "subnet_b" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/subnet/aws"
  version = "~> 1.0.5"

  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.subnet_cidr_b
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name_prefix}-subnet-b" })
}

# ---------------------------------------------------------------------------
# Endpoint security group
# Controls traffic to/from the endpoint ENIs.
# Only HTTPS (443) ingress from within the VPC is permitted.
# ---------------------------------------------------------------------------

module "endpoint_sg" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/security_group/aws"
  version = "~> 0.7.3"

  name        = "${var.name_prefix}-vpce-sg"
  description = "Security group for S3 interface endpoint"
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpce-sg" })
}

# Allow HTTPS traffic from the VPC CIDR to reach the endpoint ENIs.
module "endpoint_sg_ingress_https" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/vpc_security_group_ingress_rule/aws"
  version = "~> 0.1.4"

  security_group_id = module.endpoint_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.vpc_cidr_block
  description       = "HTTPS from VPC"

  tags = var.tags
}

# Allow all egress so the endpoint ENIs can respond to callers. In production
# you may want to scope this to the S3 prefix list instead.
module "endpoint_sg_egress_all" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/vpc_security_group_egress_rule/aws"
  version = "~> 0.2.2"

  security_group_id = module.endpoint_sg.id
  ip_protocol       = "-1"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress"

  tags = var.tags
}

# ---------------------------------------------------------------------------
# VPC endpoint under test
# Interface endpoint for S3 in the region, placed in both private subnets.
# private_dns_enabled is false here so tests do not override default service
# hostname resolution in shared environments. Set it to true in production when
# private resolution to the endpoint is desired.
# ---------------------------------------------------------------------------
module "vpc_endpoint" {
  source = "../.."

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = false
  subnet_ids          = [module.subnet_a.subnet_id, module.subnet_b.subnet_id]
  security_group_ids  = [module.endpoint_sg.id]
  policy              = var.endpoint_policy

  tags = var.tags
}
