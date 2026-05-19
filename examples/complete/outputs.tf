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

output "vpc_id" {
  description = "VPC ID used by the example."
  value       = module.vpc.vpc_id
}

output "region" {
  description = "AWS region used by the example deployment."
  value       = var.region
}

output "subnet_ids" {
  description = "Subnet IDs associated with the endpoint."
  value       = [module.subnet_a.subnet_id, module.subnet_b.subnet_id]
}

output "endpoint_security_group_id" {
  description = "Security group ID attached to the endpoint."
  value       = module.endpoint_sg.id
}

output "endpoint_id" {
  description = "VPC endpoint ID."
  value       = module.vpc_endpoint.id
}

output "endpoint_arn" {
  description = "VPC endpoint ARN."
  value       = module.vpc_endpoint.arn
}

output "endpoint_state" {
  description = "Current state of the VPC endpoint."
  value       = module.vpc_endpoint.state
}

output "endpoint_dns_entries" {
  description = "DNS entries for the VPC endpoint."
  value       = module.vpc_endpoint.dns_entry
}
