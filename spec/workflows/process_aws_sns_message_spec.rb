require "rails_helper"

describe ProcessAwsSnsMessage do
  fit "creates the SNS Message" do
    headers = {
      "HTTP_X_AMZ_SNS_MESSAGE_TYPE" => "Notification",
      "HTTP_X_AMZ_SNS_MESSAGE_ID" => SecureRandom.uuid
    }
    payload = file_fixture("aws_sns_message.json").read

    aws_sns_message = described_class.call(headers, payload)

    expect(aws_sns_message).to have_attributes(
      headers: headers,
      payload: JSON.parse(payload),
      type: "notification",
      aws_sns_message_id: headers.fetch("HTTP_X_AMZ_SNS_MESSAGE_ID")
    )
  end
end
