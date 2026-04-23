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

# ---------------------------------------------------------------------------
# Core identity
# ---------------------------------------------------------------------------

output "id" {
  description = "The ID of the VPC endpoint (e.g. vpce-0abc123)."
  value       = aws_vpc_endpoint.this.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the VPC endpoint."
  value       = aws_vpc_endpoint.this.arn
}

# ---------------------------------------------------------------------------
# Operational state
# ---------------------------------------------------------------------------

output "state" {
  description = "The current state of the VPC endpoint. Common values: pendingAcceptance, pending, available, deleting, deleted."
  value       = aws_vpc_endpoint.this.state
}

# ---------------------------------------------------------------------------
# Interface endpoint outputs
# (populated only for Interface type endpoints)
# ---------------------------------------------------------------------------

output "dns_entry" {
  description = "The DNS entries for the VPC endpoint. Each entry is an object containing dns_name (the hostname) and hosted_zone_id (the Route 53 hosted zone). Use these values to configure DNS resolution or alias records."
  value       = aws_vpc_endpoint.this.dns_entry
}

output "network_interface_ids" {
  description = "List of network interface IDs created for the endpoint ENIs. Populated for Interface type endpoints only. Useful for attaching additional security group rules or for network flow log analysis."
  value       = aws_vpc_endpoint.this.network_interface_ids
}

# ---------------------------------------------------------------------------
# Gateway endpoint outputs
# (populated only for Gateway type endpoints)
# ---------------------------------------------------------------------------

output "prefix_list_id" {
  description = "The managed prefix list ID representing the AWS service CIDR ranges. Populated for Gateway type endpoints only. Can be referenced in security group rules to allow traffic to the service without specifying IP ranges directly."
  value       = aws_vpc_endpoint.this.prefix_list_id
}

# ---------------------------------------------------------------------------
# Policy
# ---------------------------------------------------------------------------

output "policy" {
  description = "The JSON access policy attached to the endpoint. Returns null when no custom policy was provided (AWS default full-access policy is in effect)."
  value       = var.policy != null ? aws_vpc_endpoint_policy.this[0].policy : null
}
