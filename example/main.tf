module "cloudwatch-monitor" {
  source  = "../"
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