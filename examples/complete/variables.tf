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

variable "region" {
  description = "AWS region for the example deployment."
  type        = string
  default     = "us-east-2"
}

variable "name_prefix" {
  description = "Prefix for resource names in the example."
  type        = string
  default     = "vpce-example"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the example VPC."
  type        = string
  default     = "10.48.0.0/16"
}

variable "subnet_cidr_a" {
  description = "CIDR block for the first private subnet."
  type        = string
  default     = "10.48.10.0/24"
}

variable "subnet_cidr_b" {
  description = "CIDR block for the second private subnet."
  type        = string
  default     = "10.48.11.0/24"
}

variable "endpoint_policy" {
  description = "Optional JSON policy document to attach to the VPC endpoint."
  type        = string
  default     = null
}

variable "service_name" {
  description = "Optional endpoint service name override (for example com.amazonaws.us-east-2.s3). When null, defaults to regional S3 for var.region."
  type        = string
  default     = null
}

variable "vpc_endpoint_type" {
  description = "Endpoint type passed to the module. Valid values: Interface, Gateway, GatewayLoadBalancer."
  type        = string
  default     = "Interface"

  validation {
    condition     = contains(["Interface", "Gateway", "GatewayLoadBalancer"], var.vpc_endpoint_type)
    error_message = "vpc_endpoint_type must be one of: Interface, Gateway, GatewayLoadBalancer."
  }
}

variable "private_dns_enabled" {
  description = "Whether to enable private DNS on Interface endpoints. Ignored for non-Interface types."
  type        = bool
  default     = false
}

variable "endpoint_subnet_ids" {
  description = "Optional subnet IDs to pass into the endpoint module. When null, uses the two subnets created by this example."
  type        = list(string)
  default     = null
}

variable "endpoint_security_group_ids" {
  description = "Optional security group IDs to pass into the endpoint module. When null, uses the endpoint security group created by this example."
  type        = list(string)
  default     = null
}

variable "route_table_ids" {
  description = "Route table IDs for Gateway endpoints. Ignored for Interface and GatewayLoadBalancer endpoint types."
  type        = list(string)
  default     = []
}

variable "auto_accept" {
  description = "Whether to auto-accept the endpoint request."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "IP address type for the endpoint. Valid values: ipv4, dualstack, ipv6. Null uses the service default."
  type        = string
  default     = null

  validation {
    condition     = var.ip_address_type == null ? true : contains(["ipv4", "dualstack", "ipv6"], var.ip_address_type)
    error_message = "ip_address_type must be one of: ipv4, dualstack, ipv6, or null."
  }
}

variable "dns_options" {
  description = "Optional DNS options for Interface endpoints. Ignored for non-Interface endpoint types."
  type = object({
    dns_record_ip_type                             = optional(string)
    private_dns_only_for_inbound_resolver_endpoint = optional(bool)
  })
  default = null
}

variable "tags" {
  description = "Tags applied to all resources in this example."
  type        = map(string)
  default = {
    Environment = "test"
    Owner       = "terratest"
    Service     = "vpc-endpoint"
  }
}
