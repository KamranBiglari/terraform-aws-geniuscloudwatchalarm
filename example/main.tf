module "cloudwatch-monitor" {
  source  = "../"
  input = "${path.module}/cloudwatch.yaml"
  alarm_name_prefix = "cloudwatch-monitor"
  current_environment = "dev"
  template_data = {
    rediscluster = {}
    websocketmonitoring = module.websocketmonitoring #
  }
  alarm_actions = {
    default = {
      alarm = ""
      ok = ""
    }
  }
}

module "websocketmonitoring" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 3.0"
  name              = "/APP_NAME/websocket-monitoring"
  retention_in_days = 14
}