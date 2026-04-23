# Test

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
| <a name="input_auto_accept"></a> [auto\_accept](#input\_auto\_accept) | Accept the VPC endpoint request automatically (only for endpoints within same account). | `bool` | `false` | no |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Whether to enable private DNS for the endpoint. Applies to Interface endpoints only. | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs in which to create endpoint network interfaces. Applies to Interface and GatewayLoadBalancer endpoints. | `list(string)` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the endpoint network interfaces. Applies to Interface endpoints only. | `list(string)` | `[]` | no |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | List of route table IDs to associate with the endpoint. Applies to Gateway endpoints only. | `list(string)` | `[]` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The IP address type for the endpoint. Valid values: ipv4, dualstack, ipv6. Defaults to the service default when null. | `string` | `null` | no |
| <a name="input_dns_options"></a> [dns\_options](#input\_dns\_options) | DNS options for the endpoint. Applies to Interface endpoints only. | <pre>object({<br/>    dns_record_ip_type                             = optional(string)<br/>    private_dns_only_for_inbound_resolver_endpoint = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A policy document to attach to the endpoint controlling access to the service. When null, the default full-access policy is used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the VPC endpoint resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | The ID of the VPC endpoint. |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the VPC endpoint. |
| <a name="output_state"></a> [state](#output\_state) | The current state of the VPC endpoint. |
| <a name="output_dns_entry"></a> [dns\_entry](#output\_dns\_entry) | The DNS entries for the VPC endpoint. Each entry contains dns\_name and hosted\_zone\_id. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | List of network interface IDs created for the endpoint. Populated for Interface type endpoints. |
| <a name="output_prefix_list_id"></a> [prefix\_list\_id](#output\_prefix\_list\_id) | The prefix list ID for the exposed AWS service. Populated for Gateway type endpoints. |
| <a name="output_policy"></a> [policy](#output\_policy) | The policy document attached to the endpoint. |
<!-- END_TF_DOCS -->
