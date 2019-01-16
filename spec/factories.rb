FactoryBot.define do
  sequence(:external_id) { SecureRandom.uuid }
  sequence :phone_number, 855_972_345_678, &:to_s

  trait :with_status_callback_url do
    status_callback_url { "https://rapidpro.ngrok.com/handle/33/" }
  end

  trait :with_status_callback_method do
    status_callback_method { "POST" }
  end

  trait :with_voice_method do
    status_callback_method { "GET" }
  end

  factory :freeswitch_cdr do
    transient do
      transient_cdr { { "variables" => {} } }
      sip_term_status { nil }
    end

    trait :busy do
      sip_term_status { "486" }
    end

    skip_create
    initialize_with do
      transient_cdr["variables"]["sip_term_status"] = sip_term_status if sip_term_status
      cdr_json = JSON.parse(File.read(ActiveSupport::TestCase.fixture_path + "/freeswitch_cdr.json"))
      cdr_json.deep_merge!(transient_cdr)
      new(cdr_json.to_json)
    end
  end

  factory :aws_sns_message_base, class: AwsSnsMessage::Base do
    transient do
      raw_payload do
        "{\n  \"Type\" : \"#{sns_message_type}\",\n  \"MessageId\" : \"#{sns_message_id}\",\n  \"TopicArn\" : \"#{sns_topic_arn}\",\n  \"Subject\" : \"#{sns_message_subject}\",\n  \"Message\" : \"{\\\"Records\\\":[{\\\"eventVersion\\\":\\\"2.0\\\",\\\"eventSource\\\":\\\"#{sns_message_event_source}\\\",\\\"awsRegion\\\":\\\"ap-southeast-1\\\",\\\"eventTime\\\":\\\"2017-08-31T06:00:05.262Z\\\",\\\"eventName\\\":\\\"#{sns_message_event_name}\\\",\\\"userIdentity\\\":{\\\"principalId\\\":\\\"AWS:AROAJ2HUUZYOOO65N2QGI:i-0d4d562bc5c622959\\\"},\\\"requestParameters\\\":{\\\"sourceIPAddress\\\":\\\"10.0.2.216\\\"},\\\"responseElements\\\":{\\\"x-amz-request-id\\\":\\\"3F8010558C5472DA\\\",\\\"x-amz-id-2\\\":\\\"F1z++xfzffWS7zYj/xoOGgAUS9ZWv5KHJ/fJqnX8XpgtTFr2FUFApnUHLSccsCXsaSN4qU1NTdg=\\\"},\\\"s3\\\":{\\\"s3SchemaVersion\\\":\\\"1.0\\\",\\\"configurationId\\\":\\\"NjlhODdjMGYtY2YyZS00NDhmLWE1MGEtMDEyYjQ4MjBmYTQ5\\\",\\\"bucket\\\":{\\\"name\\\":\\\"#{sns_message_s3_bucket_name}\\\",\\\"ownerIdentity\\\":{\\\"principalId\\\":\\\"A3ILPUDANGSUSO\\\"},\\\"arn\\\":\\\"arn:aws:s3:::#{sns_message_s3_bucket_name}\\\"},\\\"object\\\":{\\\"key\\\":\\\"#{sns_message_s3_object_id}\\\",\\\"size\\\":144684,\\\"eTag\\\":\\\"855a2e306bcf5dab77c31e9ad73237b8\\\",\\\"sequencer\\\":\\\"0059A7A5E52F0A64D3\\\"}}}]}\",\n  \"Timestamp\" : \"2017-08-31T06:00:05.362Z\",\n  \"SignatureVersion\" : \"1\",\n  \"Signature\" : \"M/ChP5IJ94aoM8RA0aojT0j/+8ssYNWmFknfApHRg4o3uxZS4ChoLiTbiB41rEP6vLpYTNFPuBaOZefURaemr91VCHoj05tTQOmd88GQnrUPpPI0UYJRJQg3GZhVfclxjcpHHSJNl6QErZ5Xg2BN8aZmR2ZadDZs1GB0b8nuRJVK4AUDD4Y21/1Kh+I13DSgCqf7OvaX2hSCf5FjOkScXcbk42/kA3rsK+3AiHp8zMvRaN51imKYkQ+ra54MnBdYzjNAPQasDcQrG56sVli26u4tl5nWpf1RQjPYj4v/8ampLMfhlWDqNcH/hqXBSRnZvytBymzWYOJVyuKWfQluGQ==\",\n  \"SigningCertURL\" : \"https://sns.ap-southeast-1.amazonaws.com/SimpleNotificationService-433026a4050d206028891664da859041.pem\",\n  \"UnsubscribeURL\" : \"https://sns.ap-southeast-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=#{sns_subscription_arn}:38406e55-f60b-48fd-8faf-6d41544bfab3\"\n}"
      end

      sns_message_type { "" }
      sns_message_id { SecureRandom.uuid }
      sns_topic_arn { "arn:aws:sns:us-west-2:123456789012:MyTopic" }
      sns_message_subject { "My First Message" }
      sns_message_s3_bucket_name { "bucket-name" }
      sns_message_s3_object_id { "recordings/abcdefb2-f8be-4a06-b6ac-158c082b38ca-2.wav" }
      sns_subscription_arn { "#{sns_topic_arn}:abcdee55-f60b-48fd-8faf-6d41544bfab3" }
      sns_message_event_source { "aws:s3" }
      sns_message_event_name { "ObjectCreated:Put" }
    end

    aws_sns_message_id { sns_message_id }

    payload { JSON.parse(raw_payload) }

    factory :aws_sns_message_subscription_confirmation, class: AwsSnsMessage::SubscriptionConfirmation do
      sns_message_type { "SubscriptionConfirmation" }
    end

    factory :aws_sns_message_notification, class: AwsSnsMessage::Notification do
      sns_message_type { "Notification" }
    end
  end

  factory :recording do
    transient do
      status_callback_url { nil }
      status_callback_method { nil }
    end

    association :phone_call

    trait :initiated do
      status { "initiated" }
    end

    trait :waiting_for_file do
      status { "waiting_for_file" }
    end

    trait :processing do
      status { "processing" }
    end

    trait :completed do
      status { "completed" }
    end

    trait :can_complete do
      processing
    end

    trait :with_wav_file do
      file do
        Refile::FileDouble.new(
          "dummy",
          "recording.wav",
          content_type: "audio/x-wav"
        )
      end
    end

    twiml_instructions do
      twiml_instructions = {}
      twiml_instructions["recordingStatusCallback"] = status_callback_url if status_callback_url
      twiml_instructions["recordingStatusCallbackMethod"] = status_callback_method if status_callback_method
      twiml_instructions
    end
  end

  factory :call_data_record do
    transient do
      cdr { build(:freeswitch_cdr) }
      account { build(:account) }
      external_id { generate(:external_id) }
    end

    after(:build) do |call_data_record, evaluator|
      call_data_record.phone_call ||= build(
        :phone_call, account: evaluator.account, external_id: evaluator.external_id
      )
    end

    trait :inbound do
      direction { "inbound" }
    end

    trait :outbound do
      direction { "outbound" }
    end

    trait :billable do
      bill_sec { 1 }
      answer_time { Time.now }
    end

    trait :not_billable do
      bill_sec { 0 }
      answer_time { nil }
    end

    trait :event_answered do
      billable
    end

    trait :event_not_answered do
      sip_term_status { "480" }
    end

    trait :event_busy do
      sip_term_status { "486" }
    end

    duration_sec { cdr.duration_sec }
    bill_sec { cdr.bill_sec }
    direction { cdr.direction }
    hangup_cause { cdr.hangup_cause }
    start_time { Time.at(cdr.start_epoch.to_i) }
    end_time { Time.at(cdr.end_epoch.to_i) }
    price { Money.new(0) }

    file do
      Refile::FileDouble.new(
        cdr.raw_cdr,
        cdr.send(:filename),
        content_type: cdr.send(:content_type)
      )
    end
  end

  factory :account do
    enabled
    with_access_token

    trait :enabled do
      state { Account::STATE_ENABLED }
    end

    trait :disabled do
      state { Account::STATE_DISABLED }
    end

    trait :with_access_token do
      after(:build) do |account|
        account.access_token ||= build(:access_token, resource_owner_id: account.id)
      end
    end
  end

  factory :incoming_phone_number do
    account
    phone_number { generate(:phone_number) }
    voice_url { "https://rapidpro.ngrok.com/handle/33/" }
    voice_method { "POST" }
  end

  factory :phone_call do
    account
    to { "+85512334667" }
    from { "2442" }
    voice_url { "https://rapidpro.ngrok.com/handle/33/" }
    voice_method { "POST" }

    trait :inbound do
      incoming_phone_number
      to { incoming_phone_number.phone_number }
    end

    trait :queued do
      status { PhoneCall::STATE_QUEUED }
    end

    trait :initiated do
      status { PhoneCall::STATE_INITIATED }
    end

    trait :answered do
      status { PhoneCall::STATE_ANSWERED }
    end

    trait :not_answered do
      status { PhoneCall::STATE_NOT_ANSWERED }
    end

    trait :ringing do
      status { PhoneCall::STATE_RINGING }
    end

    trait :canceled do
      status { PhoneCall::STATE_CANCELED }
    end

    trait :failed do
      status { PhoneCall::STATE_FAILED }
    end

    trait :completed do
      status { PhoneCall::STATE_COMPLETED }
    end

    trait :busy do
      status { PhoneCall::STATE_BUSY }
    end
  end

  factory :phone_call_event do
    phone_call

    trait :recording_started do
      type { :recording_started }
    end

    trait :answered do
      type { :answered }
    end
  end

  factory :access_token, class: Doorkeeper::AccessToken

  factory :usage_record_collection do
    skip_create
    account

    transient do
      start_date { nil }
      end_date { nil }
      category { nil }
    end

    filter_params { { StartDate: start_date, EndDate: end_date, Category: category }.compact }

    initialize_with do
      new(account, filter_params)
    end
  end
end
