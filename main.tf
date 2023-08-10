variable "alarm_name_prefix" {
  type        = string
  description = "Prefix of alarm name"
}

variable "input" {
  type        = string
  description = "Path to yaml file"
}

variable "loop" {
  type    = map(any)
  default = {}
}

variable "current_environment" {
  type        = string
  description = "Current environment"
}

variable "template_data" {
  type        = map(any)
  description = "values to replace in template"
  default     = {}
}

variable "alarm_actions" {
  type        = map(any)
  description = "map of alarm actions"
  default     = {}
}

locals {
  CloudWatch = yamldecode(templatefile(var.input, var.template_data))
}

# CloudWatch Alarms
module "metric-alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.0"
  for_each = { for i in flatten([
    for Key, Value in local.CloudWatch["Cloudwatch"] : [
      for loopK, loopV in try(var.loop[Value.Loop], ["default"]) : {
        ServiceKey = loopV
        Name       = Value.Name
        Key        = Key
        Config     = Value
      }
    ]
    ]) : "${i.Name}-${i.ServiceKey}" => i
  if contains(i.Config.Environment, var.current_environment) || !can(i.Config.Environment) }
  alarm_name          = "${var.alarm_name_prefix}-${each.key}"
  alarm_description   = each.value.Config.Description
  comparison_operator = each.value.Config.Operator
  evaluation_periods  = each.value.Config.EvaluationPeriods
  threshold           = each.value.Config.Threshold

  treat_missing_data = each.value.Config.TreatMissingData

  namespace   = can(each.value.Config.Query) ? null : each.value.Config.Namespace
  metric_name = can(each.value.Config.Query) ? null : each.value.Config.Metrics
  statistic   = can(each.value.Config.Query) ? null : each.value.Config.Statistic
  dimensions  = can(each.value.Config.Query) ? null : try(tomap(each.value.Config.Dimensions), {})
  period      = can(each.value.Config.Query) ? null : each.value.Config.Period
  metric_query = can(each.value.Config.Query) ? [for qK, qV in each.value.Config.Query : {
    id          = (can(qV.expression)) ? "e${qK}" : "m${qK}"
    label       = qV.label
    return_data = try(qV.return_data, false)
    expression  = try(qV.expression, null)
    period      = try(qV.period, null)

    metric = (can(qV.metric)) ? [{
      namespace   = qV.metric.namespace
      metric_name = qV.metric.metric_name
      period      = qV.metric.period
      stat        = qV.metric.stat
      unit        = try(qV.metric.unit, null)
      dimensions  = { for dK, dV in try(qV.metric.dimensions, []) : dK => dV }
    }] : []

  }] : []


  actions_enabled = can(each.value.Config.AlarmActions) ? true : false
  alarm_actions = [for aK, aV in each.value.Config.AlarmActions.ALARM :
    try(var.alarm_actions[aK]["alarm"][aV[var.current_environment]].arn, "")
    if can(var.alarm_actions[aK]["alarm"][aV[var.current_environment]].arn)
  ]
  ok_actions = [for aK, aV in each.value.Config.AlarmActions.OK :
    try(var.alarm_actions[aK]["ok"][aV[var.current_environment]].arn, "")
    if can(var.alarm_actions[aK]["ok"][aV[var.current_environment]].arn)
  ]
}

#CloudWatch Custom Metrics
module "log-metric-filter" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 4.0"
  for_each = { for i in flatten([
    for Key, Value in local.CloudWatch["Cloudwatch"] : [
      for loopK, loopV in try(var.loop[Value.Loop], ["default"]) : {
        ServiceKey = loopV
        Name       = Value.Name
        Key        = Key
        Config     = Value
      }
    ]
    ]) : "${i.Name}-${i.ServiceKey}" => i
  if(contains(i.Config.Environment, var.current_environment) || !can(i.Config.Environment)) && can(i.Config.CustomMetrics) }

  log_group_name = each.value.Config.CustomMetrics.LogGroupName

  name    = "${each.key}-${each.value.Config.Metrics}-metricfilter"
  pattern = each.value.Config.CustomMetrics.Patten

  metric_transformation_namespace = each.value.Config.Namespace
  metric_transformation_name      = each.value.Config.Metrics
}
