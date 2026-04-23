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

// Validates required variables are enforced and optional variable defaults
// are applied correctly via plan-only runs (no AWS credentials required).

// ── Positive cases ────────────────────────────────────────────────────────────

run "valid_interface_endpoint_minimal" {
  command = plan

  variables {
    vpc_id       = "vpc-0123456789abcdef0"
    service_name = "com.amazonaws.us-east-2.s3"
  }
}

run "valid_interface_endpoint_full" {
  command = plan

  variables {
    vpc_id              = "vpc-0123456789abcdef0"
    service_name        = "com.amazonaws.us-east-2.s3"
    vpc_endpoint_type   = "Interface"
    private_dns_enabled = false
    subnet_ids          = ["subnet-aaaaaaaaaaaaaaa01", "subnet-aaaaaaaaaaaaaaa02"]
    security_group_ids  = ["sg-0123456789abcdef0"]
    ip_address_type     = "ipv4"
    tags = {
      Environment = "test"
    }
  }
}

run "valid_gateway_endpoint" {
  command = plan

  variables {
    vpc_id            = "vpc-0123456789abcdef0"
    service_name      = "com.amazonaws.us-east-2.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids   = ["rtb-0123456789abcdef0"]
  }
}

run "valid_interface_with_policy" {
  command = plan

  variables {
    vpc_id       = "vpc-0123456789abcdef0"
    service_name = "com.amazonaws.us-east-2.s3"
    policy       = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = "*", Action = "s3:GetObject", Resource = "*" }] })
  }
}

run "valid_interface_dualstack" {
  command = plan

  variables {
    vpc_id          = "vpc-0123456789abcdef0"
    service_name    = "com.amazonaws.us-east-2.s3"
    ip_address_type = "dualstack"
  }
}

run "valid_interface_ipv6" {
  command = plan

  variables {
    vpc_id          = "vpc-0123456789abcdef0"
    service_name    = "com.amazonaws.us-east-2.s3"
    ip_address_type = "ipv6"
  }
}

// ── Negative cases ────────────────────────────────────────────────────────────

run "invalid_endpoint_type" {
  command = plan

  variables {
    vpc_id            = "vpc-0123456789abcdef0"
    service_name      = "com.amazonaws.us-east-2.s3"
    vpc_endpoint_type = "BadType"
  }

  expect_failures = [var.vpc_endpoint_type]
}

run "invalid_ip_address_type" {
  command = plan

  variables {
    vpc_id          = "vpc-0123456789abcdef0"
    service_name    = "com.amazonaws.us-east-2.s3"
    ip_address_type = "invalid"
  }

  expect_failures = [var.ip_address_type]
}
