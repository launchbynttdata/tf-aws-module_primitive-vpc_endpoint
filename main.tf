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

# The primary VPC endpoint resource.
#
# Argument scoping per endpoint type:
#   Interface         — subnet_ids, security_group_ids, private_dns_enabled, dns_options
#   Gateway           — route_table_ids only (no ENIs, no security groups)
#   GatewayLoadBalancer — subnet_ids only (no security groups, no private DNS)
#
# Attributes that do not apply to a given type are set to null so the AWS provider
# omits them from the API call and avoids plan drift.
resource "aws_vpc_endpoint" "this" {
  vpc_id            = var.vpc_id
  service_name      = var.service_name
  vpc_endpoint_type = var.vpc_endpoint_type
  auto_accept       = var.auto_accept
  ip_address_type   = var.ip_address_type

  # Interface-only: private DNS requires the VPC to have enableDnsSupport and
  # enableDnsHostnames both set to true.
  private_dns_enabled = var.vpc_endpoint_type == "Interface" ? var.private_dns_enabled : null

  # Interface + GatewayLoadBalancer: one ENI is placed per subnet.
  # Gateway endpoints use route table entries instead of ENIs.
  subnet_ids = var.vpc_endpoint_type == "Interface" ? var.subnet_ids : null

  # Interface-only: security groups control traffic to and from the endpoint ENIs.
  security_group_ids = var.vpc_endpoint_type == "Interface" ? var.security_group_ids : null

  # Gateway-only: the endpoint is advertised via entries in the specified route tables.
  route_table_ids = var.vpc_endpoint_type == "Gateway" ? var.route_table_ids : null

  # Optional DNS customization for Interface endpoints (e.g. dualstack record types).
  # The block is omitted entirely when dns_options is null.
  dynamic "dns_options" {
    for_each = var.dns_options != null ? [var.dns_options] : []
    content {
      dns_record_ip_type                             = dns_options.value.dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = dns_options.value.private_dns_only_for_inbound_resolver_endpoint
    }
  }

  tags = var.tags
}

# Attach a resource-based access policy to the endpoint.
#
# When var.policy is null (default) this resource is not created and AWS applies
# its default full-access policy. Providing a JSON policy string here creates a
# separate aws_vpc_endpoint_policy resource so the policy can be updated without
# replacing the endpoint itself.
resource "aws_vpc_endpoint_policy" "this" {
  count = var.policy != null ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.this.id
  policy          = var.policy
}
