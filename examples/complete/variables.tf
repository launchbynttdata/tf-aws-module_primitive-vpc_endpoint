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

variable "tags" {
  description = "Tags applied to all resources in this example."
  type        = map(string)
  default = {
    Environment = "test"
    Owner       = "terratest"
    Service     = "vpc-endpoint"
  }
}
