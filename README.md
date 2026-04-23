# tf-aws-module_primitive-vpc_endpoint

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

A Terraform primitive module for creating and managing [AWS VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html). VPC endpoints allow resources inside a VPC to communicate privately with AWS services and VPC endpoint services without requiring internet gateways, NAT devices, VPN connections, or AWS Direct Connect connections.

This module supports all three endpoint types — **Interface**, **Gateway**, and **GatewayLoadBalancer** — and conditionally applies the correct set of arguments for each type. An optional resource-based access policy can be attached to restrict which principals and actions are permitted through the endpoint.

## Features

- **All Endpoint Types**: Supports Interface (PrivateLink), Gateway (S3/DynamoDB), and GatewayLoadBalancer endpoints
- **Type-Aware Configuration**: Automatically scopes subnet IDs, security groups, route table IDs, and private DNS to the correct endpoint type
- **Custom Access Policies**: Attach an IAM resource policy via `aws_vpc_endpoint_policy` to restrict endpoint access; omit for default full-access
- **DNS Customization**: Configurable `dns_options` block for Interface endpoints including dualstack and IPv6 record types
- **IP Address Types**: Supports `ipv4`, `dualstack`, and `ipv6` address families
- **Flexible Tagging**: Pass any tag map; applied directly to the endpoint resource
- **Input Validation**: Built-in validation for `vpc_endpoint_type` and `ip_address_type` values

## Usage

### Interface Endpoint (S3 over PrivateLink)

```hcl
module "vpc_endpoint" {
  source = "github.com/launchbynttdata/tf-aws-module_primitive-vpc_endpoint?ref=1.0.0"

  vpc_id              = "vpc-0abc123"
  service_name        = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = false
  subnet_ids          = ["subnet-aaa", "subnet-bbb"]
  security_group_ids  = ["sg-123"]

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Gateway Endpoint (S3 or DynamoDB)

```hcl
module "vpc_endpoint" {
  source = "github.com/launchbynttdata/tf-aws-module_primitive-vpc_endpoint?ref=1.0.0"

  vpc_id            = "vpc-0abc123"
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = ["rtb-aaa", "rtb-bbb"]

  tags = {
    Environment = "production"
  }
}
```

### Interface Endpoint with Custom Access Policy

```hcl
module "vpc_endpoint" {
  source = "github.com/launchbynttdata/tf-aws-module_primitive-vpc_endpoint?ref=1.0.0"

  vpc_id              = "vpc-0abc123"
  service_name        = "com.amazonaws.us-east-1.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["subnet-aaa"]
  security_group_ids  = ["sg-123"]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSpecificAPI"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["execute-api:Invoke"]
      Resource  = "arn:aws:execute-api:us-east-1:123456789012:abc123/*"
    }]
  })

  tags = {
    Environment = "production"
    Application = "my-api"
  }
}
```

### GatewayLoadBalancer Endpoint

```hcl
module "vpc_endpoint" {
  source = "github.com/launchbynttdata/tf-aws-module_primitive-vpc_endpoint?ref=1.0.0"

  vpc_id            = "vpc-0abc123"
  service_name      = "com.amazonaws.vpce.us-east-1.vpce-svc-0abc123"
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = ["subnet-aaa"]

  tags = {
    Environment = "production"
  }
}
```

## Important Notes

### Endpoint Type and Argument Scoping

AWS VPC endpoint types each require a different set of arguments. This module automatically scopes attributes to the appropriate type:

| Attribute | Interface | Gateway | GatewayLoadBalancer |
|---|---|---|---|
| `subnet_ids` | ✅ | ❌ | ✅ |
| `security_group_ids` | ✅ | ❌ | ❌ |
| `private_dns_enabled` | ✅ | ❌ | ❌ |
| `route_table_ids` | ❌ | ✅ | ❌ |
| `dns_options` | ✅ | ❌ | ❌ |

Passing attributes for a different type is silently ignored by the module — they are not forwarded to the resource.

### Access Policies

When `policy` is `null` (default), AWS applies a default policy that grants full access to the service. To restrict access, provide a JSON policy string. The policy is managed via a separate `aws_vpc_endpoint_policy` resource, which allows it to be updated independently of the endpoint itself.

### Private DNS for Interface Endpoints

Setting `private_dns_enabled = true` requires that the VPC has both `enableDnsSupport` and `enableDnsHostnames` enabled. Without these VPC settings, the endpoint will fail to provision private DNS entries.

### Service Name Format

AWS service names follow the pattern `com.amazonaws.<region>.<service>` (e.g., `com.amazonaws.us-east-1.s3`). For partner or custom services, the name follows `com.amazonaws.vpce.<region>.<service-id>`. Use the AWS CLI or console to discover available service names for your region.

## Development Setup

Install required development dependencies:

```bash
make configure-dependencies
make configure-git-hooks
```

This installs:
- Terraform
- Go
- Pre-commit hooks
- Other development tools specified in `.tool-versions`

## Testing

Tests are implemented using [Terratest](https://github.com/gruntwork-io/terratest) and the [LCAF testing framework](https://github.com/launchbynttdata/lcaf-component-terratest).

```bash
# Run the full test suite (deploys real AWS resources)
make test
```

The test suite deploys the `examples/complete` configuration, verifies the endpoint reaches `available` state via the AWS EC2 API, then destroys all resources.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.41.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which to create the endpoint. | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The service name for the endpoint (e.g. com.amazonaws.us-east-1.s3). | `string` | n/a | yes |
| <a name="input_vpc_endpoint_type"></a> [vpc\_endpoint\_type](#input\_vpc\_endpoint\_type) | The VPC endpoint type. Valid values: Interface, Gateway, GatewayLoadBalancer. | `string` | `"Interface"` | no |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Whether to enable private DNS for the endpoint. Applies to Interface endpoints only. Requires the VPC to have enableDnsSupport and enableDnsHostnames both set to true. | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs in which to create endpoint network interfaces. Applies to Interface and GatewayLoadBalancer endpoints. | `list(string)` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the endpoint network interfaces. Applies to Interface endpoints only. | `list(string)` | `[]` | no |
| <a name="input_dns_options"></a> [dns\_options](#input\_dns\_options) | DNS options for the endpoint. Applies to Interface endpoints only. Set dns\_record\_ip\_type to control whether A, AAAA, or dualstack records are created. Set private\_dns\_only\_for\_inbound\_resolver\_endpoint to true to restrict private DNS to Route 53 Resolver inbound endpoints. | <pre>object({<br/>    dns_record_ip_type                             = optional(string)<br/>    private_dns_only_for_inbound_resolver_endpoint = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | List of route table IDs to associate with the endpoint. Applies to Gateway endpoints only. The AWS provider will add prefix-list routes targeting this endpoint to each specified route table. | `list(string)` | `[]` | no |
| <a name="input_auto_accept"></a> [auto\_accept](#input\_auto\_accept) | Accept the VPC endpoint request automatically. Only relevant for endpoint services in the same AWS account; cross-account requests require explicit acceptance by the service owner. | `bool` | `false` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The IP address type for the endpoint. Valid values: ipv4, dualstack, ipv6. When null the service default is used. | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A JSON policy document to attach to the endpoint controlling which principals and actions are permitted. When null, AWS applies a default policy that allows full access to the service. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the VPC endpoint resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | The ID of the VPC endpoint (e.g. vpce-0abc123). |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the VPC endpoint. |
| <a name="output_state"></a> [state](#output\_state) | The current state of the VPC endpoint. Common values: pendingAcceptance, pending, available, deleting, deleted. |
| <a name="output_dns_entry"></a> [dns\_entry](#output\_dns\_entry) | The DNS entries for the VPC endpoint. Each entry is an object containing dns\_name (the hostname) and hosted\_zone\_id (the Route 53 hosted zone). Use these values to configure DNS resolution or alias records. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | List of network interface IDs created for the endpoint ENIs. Populated for Interface type endpoints only. Useful for attaching additional security group rules or for network flow log analysis. |
| <a name="output_prefix_list_id"></a> [prefix\_list\_id](#output\_prefix\_list\_id) | The managed prefix list ID representing the AWS service CIDR ranges. Populated for Gateway type endpoints only. Can be referenced in security group rules to allow traffic to the service without specifying IP ranges directly. |
| <a name="output_policy"></a> [policy](#output\_policy) | The JSON access policy attached to the endpoint. Returns null when no custom policy was provided (AWS default full-access policy is in effect). |
<!-- END_TF_DOCS -->
