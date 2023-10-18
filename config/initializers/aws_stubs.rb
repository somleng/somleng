if Rails.env.development? || Rails.env.test?
  ENV["AWS_DEFAULT_REGION"] ||= "ap-southeast-1"
  ENV["AWS_ACCESS_KEY_ID"] ||= "access-key-id"
  ENV["AWS_SECRET_ACCESS_KEY"] ||= "secret-key"

  Aws.config[:sqs] ||= {
    stub_responses: {
      send_message: Aws::SQS::Client.new.stub_data(:send_message)
    }
  }

  Aws.config[:polly] ||= {
    stub_responses: {
      describe_voices: Aws::Polly::Client.new.stub_data(:describe_voices)
    }
  }
end
