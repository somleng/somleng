class AwsSnsMessage::NotificationObserver < AwsSnsMessage::BaseObserver
  attr_accessor :json_payload_message

  def aws_sns_message_notification_created(aws_sns_message)
    self.aws_sns_message = aws_sns_message
    self.json_payload_message = payload_message_to_hash
  end

  private

  def payload_message_to_hash
    JSON.parse(aws_sns_message.payload_message) rescue {}
  end

  def json_payload_message_records
    json_payload_message["Records"] || {}
  end

  def json_payload_message_record
    json_payload_message_records[0] || {}
  end

  def s3_record
    json_payload_message_record["s3"] || {}
  end

  def s3_bucket
    s3_record["bucket"] || {}
  end

  def s3_bucket_name
    s3_bucket["name"]
  end

  def s3_object
    s3_record["object"] || {}
  end

  def s3_object_key
    s3_object["key"]
  end
end
