class AwsSnsMessage::NotificationObserver < AwsSnsMessage::BaseObserver
  S3_EVENT_SOURCE = "aws:s3"
  S3_OBJECT_CREATED_PUT = "ObjectCreated:Put"

  attr_accessor :json_payload_message

  def aws_sns_message_notification_received(aws_sns_message)
    setup_observer(aws_sns_message)
    aws_sns_message.recording = recording if s3_object_created_notification?
  end

  def aws_sns_message_notification_created(aws_sns_message)
    setup_observer(aws_sns_message)
    RecordingProcessorJob.perform_later(
      aws_sns_message.recording_id, s3_bucket_name, s3_object_key
    ) if aws_sns_message.recording_id?
  end

  private

  def recording
    @recording ||= Recording.waiting_for_file.where.not(
      :original_file_id => nil
    ).where(
      :original_file_id => UUIDFilename.uuid_from_uri(s3_object_key)
    ).first
  end

  def setup_observer(aws_sns_message)
    self.aws_sns_message = aws_sns_message
    self.json_payload_message = payload_message_to_hash
  end

  def s3_object_created_notification?
    s3_object_created_put? && s3_bucket_name && s3_object_key
  end

  def payload_message_to_hash
    JSON.parse(aws_sns_message.payload_message) rescue {}
  end

  def json_payload_message_records
    json_payload_message["Records"] || {}
  end

  def json_payload_message_record
    json_payload_message_records[0] || {}
  end

  def event_name
    json_payload_message_record["eventName"]
  end

  def event_source
    json_payload_message_record["eventSource"]
  end

  def s3_object_created_put?
    event_source == S3_EVENT_SOURCE && event_name == S3_OBJECT_CREATED_PUT
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
