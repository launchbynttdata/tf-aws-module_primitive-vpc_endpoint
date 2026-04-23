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
# Required
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Endpoint type
# ---------------------------------------------------------------------------

variable "vpc_endpoint_type" {
  description = "The VPC endpoint type. Valid values: Interface, Gateway, GatewayLoadBalancer."
  type        = string
  default     = "Interface"

  validation {
    condition     = contains(["Interface", "Gateway", "GatewayLoadBalancer"], var.vpc_endpoint_type)
    error_message = "vpc_endpoint_type must be one of: Interface, Gateway, GatewayLoadBalancer."
  }
}

# ---------------------------------------------------------------------------
# Interface endpoint settings
# (ignored by the resource when vpc_endpoint_type != "Interface")
# ---------------------------------------------------------------------------

variable "private_dns_enabled" {
  description = "Whether to enable private DNS for the endpoint. Applies to Interface endpoints only. Requires the VPC to have enableDnsSupport and enableDnsHostnames both set to true."
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

variable "dns_options" {
  description = "DNS options for the endpoint. Applies to Interface endpoints only. Set dns_record_ip_type to control whether A, AAAA, or dualstack records are created. Set private_dns_only_for_inbound_resolver_endpoint to true to restrict private DNS to Route 53 Resolver inbound endpoints."
  type = object({
    dns_record_ip_type                             = optional(string)
    private_dns_only_for_inbound_resolver_endpoint = optional(bool)
  })
  default = null
}

# ---------------------------------------------------------------------------
# Gateway endpoint settings
# (ignored by the resource when vpc_endpoint_type != "Gateway")
# ---------------------------------------------------------------------------

variable "route_table_ids" {
  description = "List of route table IDs to associate with the endpoint. Applies to Gateway endpoints only. The AWS provider will add prefix-list routes targeting this endpoint to each specified route table."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Common settings
# ---------------------------------------------------------------------------

variable "auto_accept" {
  description = "Accept the VPC endpoint request automatically. Only relevant for endpoint services in the same AWS account; cross-account requests require explicit acceptance by the service owner."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "The IP address type for the endpoint. Valid values: ipv4, dualstack, ipv6. When null the service default is used."
  type        = string
  default     = null

  validation {
    condition     = var.ip_address_type == null ? true : contains(["ipv4", "dualstack", "ipv6"], var.ip_address_type)
    error_message = "ip_address_type must be one of: ipv4, dualstack, ipv6, or null."
  }
}

# ---------------------------------------------------------------------------
# Access policy
# ---------------------------------------------------------------------------

variable "policy" {
  description = "A JSON policy document to attach to the endpoint controlling which principals and actions are permitted. When null, AWS applies a default policy that allows full access to the service."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Tagging
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to the VPC endpoint resource."
  type        = map(string)
  default     = {}
}
