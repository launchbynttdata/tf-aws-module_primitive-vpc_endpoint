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

output "id" {
  description = "The ID of the VPC endpoint."
  value       = aws_vpc_endpoint.this.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the VPC endpoint."
  value       = aws_vpc_endpoint.this.arn
}

output "state" {
  description = "The current state of the VPC endpoint."
  value       = aws_vpc_endpoint.this.state
}

output "dns_entry" {
  description = "The DNS entries for the VPC endpoint. Each entry contains dns_name and hosted_zone_id."
  value       = aws_vpc_endpoint.this.dns_entry
}

output "network_interface_ids" {
  description = "List of network interface IDs created for the endpoint. Populated for Interface type endpoints."
  value       = aws_vpc_endpoint.this.network_interface_ids
}

output "prefix_list_id" {
  description = "The prefix list ID for the exposed AWS service. Populated for Gateway type endpoints."
  value       = aws_vpc_endpoint.this.prefix_list_id
}

output "policy" {
  description = "The policy document attached to the endpoint."
  value       = var.policy != null ? aws_vpc_endpoint_policy.this[0].policy : null
}
