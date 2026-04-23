# complete

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform.registry.launch.nttdata.com/module_primitive/vpc/aws | ~> 1.0.5 |
| <a name="module_subnet_a"></a> [subnet\_a](#module\_subnet\_a) | terraform.registry.launch.nttdata.com/module_primitive/subnet/aws | ~> 1.0.5 |
| <a name="module_subnet_b"></a> [subnet\_b](#module\_subnet\_b) | terraform.registry.launch.nttdata.com/module_primitive/subnet/aws | ~> 1.0 |
| <a name="module_endpoint_sg"></a> [endpoint\_sg](#module\_endpoint\_sg) | terraform.registry.launch.nttdata.com/module_primitive/security_group/aws | ~> 0.7.3 |
| <a name="module_endpoint_sg_ingress_https"></a> [endpoint\_sg\_ingress\_https](#module\_endpoint\_sg\_ingress\_https) | terraform.registry.launch.nttdata.com/module_primitive/vpc_security_group_ingress_rule/aws | ~> 0.1.4 |
| <a name="module_endpoint_sg_egress_all"></a> [endpoint\_sg\_egress\_all](#module\_endpoint\_sg\_egress\_all) | terraform.registry.launch.nttdata.com/module_primitive/vpc_security_group_egress_rule/aws | ~> 0.2.2 |
| <a name="module_vpc_endpoint"></a> [vpc\_endpoint](#module\_vpc\_endpoint) | ../.. | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_default_security_group.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the example deployment. | `string` | `"us-east-2"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names in the example. | `string` | `"vpce-example"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block for the example VPC. | `string` | `"10.48.0.0/16"` | no |
| <a name="input_subnet_cidr_a"></a> [subnet\_cidr\_a](#input\_subnet\_cidr\_a) | CIDR block for the first private subnet. | `string` | `"10.48.10.0/24"` | no |
| <a name="input_subnet_cidr_b"></a> [subnet\_cidr\_b](#input\_subnet\_cidr\_b) | CIDR block for the second private subnet. | `string` | `"10.48.11.0/24"` | no |
| <a name="input_endpoint_policy"></a> [endpoint\_policy](#input\_endpoint\_policy) | Optional JSON policy document to attach to the VPC endpoint. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources in this example. | `map(string)` | <pre>{<br/>  "Environment": "test",<br/>  "Owner": "terratest",<br/>  "Service": "vpc-endpoint"<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID used by the example. |
| <a name="output_region"></a> [region](#output\_region) | AWS region used by the example deployment. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Subnet IDs associated with the endpoint. |
| <a name="output_endpoint_security_group_id"></a> [endpoint\_security\_group\_id](#output\_endpoint\_security\_group\_id) | Security group ID attached to the endpoint. |
| <a name="output_endpoint_id"></a> [endpoint\_id](#output\_endpoint\_id) | VPC endpoint ID. |
| <a name="output_endpoint_arn"></a> [endpoint\_arn](#output\_endpoint\_arn) | VPC endpoint ARN. |
| <a name="output_endpoint_state"></a> [endpoint\_state](#output\_endpoint\_state) | Current state of the VPC endpoint. |
| <a name="output_endpoint_dns_entries"></a> [endpoint\_dns\_entries](#output\_endpoint\_dns\_entries) | DNS entries for the VPC endpoint. |
<!-- END_TF_DOCS -->
