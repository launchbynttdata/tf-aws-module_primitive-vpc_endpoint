# Complete Example

This example deploys a complete **Interface-type VPC endpoint** for the Amazon S3 service, including all required supporting networking resources. It demonstrates the full recommended configuration for an Interface endpoint and serves as the Terratest fixture for post-deploy functional testing.

## Purpose

This example is designed for:
- **Understanding the full module interface** — all inputs, outputs, and dependent resources are present
- **Functional testing** — used by the Terratest suite in `tests/post_deploy_functional`
- **Reference implementation** — a copy-paste starting point for real deployments
- **Exploring endpoint types** — see the [Configuration Options](#configuration-options) section for Gateway and GatewayLoadBalancer variants

## What This Example Deploys

| Resource | Purpose |
|---|---|
| VPC (`10.48.0.0/16`) | Isolated network; DNS support and hostnames enabled |
| Default Security Group | Locked down (no ingress/egress) to prevent implicit access |
| Subnet A (`10.48.10.0/24`, AZ `a`) | ENI placement for multi-AZ endpoint resiliency |
| Subnet B (`10.48.11.0/24`, AZ `b`) | ENI placement for multi-AZ endpoint resiliency |
| Security Group (`vpce-sg`) | HTTPS (443) ingress from VPC CIDR; all egress allowed |
| **VPC Endpoint** | Interface endpoint for `com.amazonaws.<region>.s3` |

## Architecture

```
VPC (10.48.0.0/16)
├── Default SG (locked down — no implicit access)
│
├── subnet-a (10.48.10.0/24)  AZ a ──┐
│                                     ├── Interface Endpoint (S3)
└── subnet-b (10.48.11.0/24)  AZ b ──┘       │
                                        Security Group (HTTPS/443 in, all out)
```

Traffic from any resource in the VPC can reach S3 over the private endpoint without traversing the internet, provided it reaches the endpoint ENI on port 443 and the ENI security group permits the source.

## Configuration Options

### Switching to a Gateway Endpoint (S3 / DynamoDB)

Gateway endpoints do not use ENIs or security groups; they inject routes into specified route tables instead. They are **free of charge** and the recommended approach for S3 and DynamoDB in most cases.

```hcl
module "vpc_endpoint" {
  source = "../.."

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = var.tags
}
```

### Enabling Private DNS

Set `private_dns_enabled = true` to resolve `s3.amazonaws.com` (or the service hostname) directly to the endpoint without updating application code. Requires the VPC to have both `enableDnsSupport` and `enableDnsHostnames` set to `true` — both are enabled in this example's VPC module call.

```hcl
module "vpc_endpoint" {
  source = "../.."

  # ... other inputs ...
  private_dns_enabled = true
}
```

### Attaching an Access Policy

By default the endpoint allows all principals full access to the service. Restrict this with a JSON policy:

```hcl
module "vpc_endpoint" {
  source = "../.."

  # ... other inputs ...
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "ReadOnlyS3"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject", "s3:ListBucket"]
      Resource  = "*"
    }]
  })
}
```

## Usage

### Prerequisites

- AWS credentials available in the environment (`AWS_PROFILE`, `AWS_DEFAULT_REGION`, or an IAM role)
- Terraform `~> 1.10` installed
- Access to the `terraform.registry.launch.nttdata.com` module registry

### Manual Deployment

```bash
# Copy the example vars file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars as needed, then:
terraform init
terraform plan
terraform apply
```

### Via Terratest (Recommended)

```bash
# From the repository root
make test
```

The test runner applies the example using `test.tfvars`, asserts the endpoint is in `available` state, then destroys all resources.

## Notes

- `private_dns_enabled` is intentionally set to `false` in this example to avoid a Route 53 private hosted zone dependency during testing. Set it to `true` in production deployments where you want transparent DNS resolution.
- The default security group is explicitly cleared of all rules to prevent unintended connectivity; this is a security best practice when using custom security groups.
- Both subnets are placed in separate AZs (`a` and `b`) to ensure the endpoint ENIs survive a single-AZ failure.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform.registry.launch.nttdata.com/module_primitive/vpc/aws | ~> 1.0.5 |
| <a name="module_subnet_a"></a> [subnet\_a](#module\_subnet\_a) | terraform.registry.launch.nttdata.com/module_primitive/subnet/aws | ~> 1.0.5 |
| <a name="module_subnet_b"></a> [subnet\_b](#module\_subnet\_b) | terraform.registry.launch.nttdata.com/module_primitive/subnet/aws | ~> 1.0 |
| <a name="module_endpoint_sg"></a> [endpoint\_sg](#module\_endpoint\_sg) | terraform.registry.launch.nttdata.com/module_primitive/security_group/aws | ~> 0.7.3 |
| <a name="module_endpoint_sg_ingress_https"></a> [endpoint\_sg\_ingress\_https](#module\_endpoint\_sg\_ingress\_https) | terraform.registry.launch.nttdata.com/module_primitive/vpc_security_group_ingress_rule/aws | ~> 0.1.4 |
| <a name="module_endpoint_sg_egress_all"></a> [endpoint\_sg\_egress\_all](#module\_endpoint\_sg\_egress\_all) | terraform.registry.launch.nttdata.com/module_primitive/vpc_security_group_egress_rule/aws | ~> 0.2.2 |
| <a name="module_vpc_endpoint"></a> [vpc\_endpoint](#module\_vpc\_endpoint) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region for the example deployment. | `string` | `"us-east-2"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names in the example. | `string` | `"vpce-example"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block for the example VPC. | `string` | `"10.48.0.0/16"` | no |
| <a name="input_subnet_cidr_a"></a> [subnet\_cidr\_a](#input\_subnet\_cidr\_a) | CIDR block for the first private subnet. | `string` | `"10.48.10.0/24"` | no |
| <a name="input_subnet_cidr_b"></a> [subnet\_cidr\_b](#input\_subnet\_cidr\_b) | CIDR block for the second private subnet. | `string` | `"10.48.11.0/24"` | no |
| <a name="input_endpoint_policy"></a> [endpoint\_policy](#input\_endpoint\_policy) | Optional JSON policy document to attach to the VPC endpoint. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources in this example. | `map(string)` | <pre>{<br/>  "Environment": "test",<br/>  "Owner": "terratest",<br/>  "Service": "vpc-endpoint"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID used by the example. |
| <a name="output_region"></a> [region](#output\_region) | AWS region used by the example deployment. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Subnet IDs associated with the endpoint. |
| <a name="output_endpoint_security_group_id"></a> [endpoint\_security\_group\_id](#output\_endpoint\_security\_group\_id) | Security group ID attached to the endpoint. |
| <a name="output_endpoint_id"></a> [endpoint\_id](#output\_endpoint\_id) | VPC endpoint ID. |
| <a name="output_endpoint_arn"></a> [endpoint\_arn](#output\_endpoint\_arn) | VPC endpoint ARN. |
| <a name="output_endpoint_state"></a> [endpoint\_state](#output\_endpoint\_state) | Current state of the VPC endpoint. |
| <a name="output_endpoint_dns_entries"></a> [endpoint\_dns\_entries](#output\_endpoint\_dns\_entries) | DNS entries for the VPC endpoint. |
<!-- END_TF_DOCS -->
