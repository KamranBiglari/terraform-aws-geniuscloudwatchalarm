[![GitHub release (latest by date)](https://img.shields.io/github/v/release/KamranBiglari/terraform-aws-geniuscloudwatchalarm)](https://github.com/KamranBiglari/terraform-aws-geniuscloudwatchalarm/releases/latest)

# terraform-aws-geniuscloudwatchalarm
A Terraform module to create multiple dynamic AWS Cloudwatch Alamrs by using YAML

## Usage
```
module "cloudwatch-monitor" {
  source  = "KamranBiglari/geniuscloudwatchalarm/aws"
  version = "~> 1.0"
  input = "${path.module}/cloudwatch.yaml"
  alarm_name_prefix = "cloudwatch-monitor"
  current_environment = "dev"
  template_data = {
    
  }
  alarm_actions = {
    default = {
      alarm = ""
      ok = ""
    }
  }
}
```

## Examples
- https://github.com/KamranBiglari/terraform-aws-geniuscloudwatchalarm/tree/main/example

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.8.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metric-alarm"></a> [metric-alarm](#module\_metric-alarm) | terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter | ~> 4.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | map of alarm actions | `map(any)` | `{}` | no |
| <a name="input_alarm_name_prefix"></a> [alarm\_name\_prefix](#input\_alarm\_name\_prefix) | Prefix of alarm name | `string` | n/a | yes |
| <a name="input_current_environment"></a> [current\_environment](#input\_current\_environment) | Current environment | `string` | n/a | yes |
| <a name="input_input"></a> [input](#input\_input) | Path to yaml file | `string` | n/a | yes |
| <a name="input_loop"></a> [loop](#input\_loop) | n/a | `map(any)` | `{}` | no |
| <a name="input_template_data"></a> [template\_data](#input\_template\_data) | values to replace in template | `map(any)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->