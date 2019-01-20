class ProcessAwsSnsMessage < ApplicationWorkflow
  attr_accessor :headers, :payload

  def initialize(headers, payload)
    self.headers = headers
    self.payload = payload
  end

  def call
    create_aws_sns_message
  end

  private

  def create_aws_sns_message
    AwsSnsMessage.create!(
      headers: headers,
      payload: JSON.parse(payload),
      type: headers.fetch("HTTP_X_AMZ_SNS_MESSAGE_TYPE").underscore,
      aws_sns_message_id: headers.fetch("HTTP_X_AMZ_SNS_MESSAGE_ID")
    )
  end
end
