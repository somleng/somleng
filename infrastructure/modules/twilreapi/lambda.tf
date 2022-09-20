data "aws_lambda_function" "call_service" {
  function_name = var.call_service_function_name
}
