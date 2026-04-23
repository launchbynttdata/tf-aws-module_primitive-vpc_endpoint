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

variable "vpc_id" {
  description = "The ID of the VPC in which to create the endpoint."
  type        = string
  nullable    = false
}

variable "service_name" {
  description = "The service name for the endpoint (e.g. com.amazonaws.us-east-1.s3)."
  type        = string
  nullable    = false
}

variable "vpc_endpoint_type" {
  description = "The VPC endpoint type. Valid values: Interface, Gateway, GatewayLoadBalancer."
  type        = string
  default     = "Interface"

  validation {
    condition     = contains(["Interface", "Gateway", "GatewayLoadBalancer"], var.vpc_endpoint_type)
    error_message = "vpc_endpoint_type must be one of: Interface, Gateway, GatewayLoadBalancer."
  }
}

variable "auto_accept" {
  description = "Accept the VPC endpoint request automatically (only for endpoints within same account)."
  type        = bool
  default     = false
}

variable "private_dns_enabled" {
  description = "Whether to enable private DNS for the endpoint. Applies to Interface endpoints only."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs in which to create endpoint network interfaces. Applies to Interface and GatewayLoadBalancer endpoints."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the endpoint network interfaces. Applies to Interface endpoints only."
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "List of route table IDs to associate with the endpoint. Applies to Gateway endpoints only."
  type        = list(string)
  default     = []
}

variable "ip_address_type" {
  description = "The IP address type for the endpoint. Valid values: ipv4, dualstack, ipv6. Defaults to the service default when null."
  type        = string
  default     = null

  validation {
    condition     = var.ip_address_type == null || contains(["ipv4", "dualstack", "ipv6"], var.ip_address_type)
    error_message = "ip_address_type must be one of: ipv4, dualstack, ipv6, or null."
  }
}

variable "dns_options" {
  description = "DNS options for the endpoint. Applies to Interface endpoints only."
  type = object({
    dns_record_ip_type                             = optional(string)
    private_dns_only_for_inbound_resolver_endpoint = optional(bool)
  })
  default = null
}

variable "policy" {
  description = "A policy document to attach to the endpoint controlling access to the service. When null, the default full-access policy is used."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the VPC endpoint resource."
  type        = map(string)
  default     = {}
}
