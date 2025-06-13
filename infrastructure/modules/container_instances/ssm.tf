# Automatically update the SSM agent

# https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-state-cli.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association
resource "aws_ssm_association" "update_ssm_agent" {
  name = "AWS-UpdateSSMAgent"

  targets {
    key    = "tag:Name"
    values = [var.identifier]
  }

  schedule_expression = "cron(0 19 ? * SAT *)"
}
