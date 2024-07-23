resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/marketvector-app"        
  retention_in_days = 30
}
