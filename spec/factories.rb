FactoryGirl.define do
  sequence :external_id do |n|
    "#{n}"
  end

  sequence :phone_number, 855972345678 do |n|
    n.to_s
  end

  trait :with_status_callback_url do
    status_callback_url "https://rapidpro.ngrok.com/handle/33/"
  end

  trait :with_status_callback_method do
    status_callback_method "POST"
  end

  trait :with_voice_method do
    status_callback_method "GET"
  end

  factory :freeswitch_cdr, :class => CDR::Freeswitch do
    transient do
      transient_cdr { {"variables" => {}} }
      sip_term_status nil
    end

    trait :busy do
      sip_term_status "486"
    end

    skip_create
    initialize_with {
      transient_cdr["variables"].merge!("sip_term_status" => sip_term_status) if sip_term_status
      cdr_json = JSON.parse(File.read(ActiveSupport::TestCase.fixture_path + "/freeswitch_cdr.json"))
      cdr_json.deep_merge!(transient_cdr)
      new(cdr_json.to_json)
    }
  end

  factory :usage_record_collection, :class => Usage::Record::Collection do
    skip_create
    account
    category "calls"
    start_date { Date.new(2015, 9, 30) }
    end_date { Date.new(2015, 10, 31) }
  end

  factory :base_usage_record, :class => Usage::Record::Base do
    skip_create
    account

    factory :calls_usage_record, :class => Usage::Record::Calls
    factory :calls_inbound_usage_record, :class => Usage::Record::CallsInbound
    factory :calls_outbound_usage_record, :class => Usage::Record::CallsOutbound
  end

  factory :aws_sns_message_base, :class => AwsSnsMessage::Base do
    transient do
      raw_payload {
        "{\n  \"Type\" : \"#{sns_message_type}\",\n  \"MessageId\" : \"#{sns_message_id}\",\n  \"TopicArn\" : \"#{sns_topic_arn}\",\n  \"Subject\" : \"#{sns_message_subject}\",\n  \"Message\" : \"{\\\"Records\\\":[{\\\"eventVersion\\\":\\\"2.0\\\",\\\"eventSource\\\":\\\"#{sns_message_event_source}\\\",\\\"awsRegion\\\":\\\"ap-southeast-1\\\",\\\"eventTime\\\":\\\"2017-08-31T06:00:05.262Z\\\",\\\"eventName\\\":\\\"#{sns_message_event_name}\\\",\\\"userIdentity\\\":{\\\"principalId\\\":\\\"AWS:AROAJ2HUUZYOOO65N2QGI:i-0d4d562bc5c622959\\\"},\\\"requestParameters\\\":{\\\"sourceIPAddress\\\":\\\"10.0.2.216\\\"},\\\"responseElements\\\":{\\\"x-amz-request-id\\\":\\\"3F8010558C5472DA\\\",\\\"x-amz-id-2\\\":\\\"F1z++xfzffWS7zYj/xoOGgAUS9ZWv5KHJ/fJqnX8XpgtTFr2FUFApnUHLSccsCXsaSN4qU1NTdg=\\\"},\\\"s3\\\":{\\\"s3SchemaVersion\\\":\\\"1.0\\\",\\\"configurationId\\\":\\\"NjlhODdjMGYtY2YyZS00NDhmLWE1MGEtMDEyYjQ4MjBmYTQ5\\\",\\\"bucket\\\":{\\\"name\\\":\\\"#{sns_message_s3_bucket_name}\\\",\\\"ownerIdentity\\\":{\\\"principalId\\\":\\\"A3ILPUDANGSUSO\\\"},\\\"arn\\\":\\\"arn:aws:s3:::#{sns_message_s3_bucket_name}\\\"},\\\"object\\\":{\\\"key\\\":\\\"#{sns_message_s3_object_id}\\\",\\\"size\\\":144684,\\\"eTag\\\":\\\"855a2e306bcf5dab77c31e9ad73237b8\\\",\\\"sequencer\\\":\\\"0059A7A5E52F0A64D3\\\"}}}]}\",\n  \"Timestamp\" : \"2017-08-31T06:00:05.362Z\",\n  \"SignatureVersion\" : \"1\",\n  \"Signature\" : \"M/ChP5IJ94aoM8RA0aojT0j/+8ssYNWmFknfApHRg4o3uxZS4ChoLiTbiB41rEP6vLpYTNFPuBaOZefURaemr91VCHoj05tTQOmd88GQnrUPpPI0UYJRJQg3GZhVfclxjcpHHSJNl6QErZ5Xg2BN8aZmR2ZadDZs1GB0b8nuRJVK4AUDD4Y21/1Kh+I13DSgCqf7OvaX2hSCf5FjOkScXcbk42/kA3rsK+3AiHp8zMvRaN51imKYkQ+ra54MnBdYzjNAPQasDcQrG56sVli26u4tl5nWpf1RQjPYj4v/8ampLMfhlWDqNcH/hqXBSRnZvytBymzWYOJVyuKWfQluGQ==\",\n  \"SigningCertURL\" : \"https://sns.ap-southeast-1.amazonaws.com/SimpleNotificationService-433026a4050d206028891664da859041.pem\",\n  \"UnsubscribeURL\" : \"https://sns.ap-southeast-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=#{sns_subscription_arn}:38406e55-f60b-48fd-8faf-6d41544bfab3\"\n}"
      }

      sns_message_type ""
      sns_message_id { SecureRandom.uuid }
      sns_topic_arn "arn:aws:sns:us-west-2:123456789012:MyTopic"
      sns_message_subject "My First Message"
      sns_message_s3_bucket_name "bucket-name"
      sns_message_s3_object_id "recordings/abcdefb2-f8be-4a06-b6ac-158c082b38ca-2.wav"
      sns_subscription_arn { "#{sns_topic_arn}:abcdee55-f60b-48fd-8faf-6d41544bfab3" }
      sns_message_event_source "aws:s3"
      sns_message_event_name "ObjectCreated:Put"
    end

    aws_sns_message_id { sns_message_id }

    payload { JSON.parse(raw_payload) }

    factory :aws_sns_message_subscription_confirmation, :class => AwsSnsMessage::SubscriptionConfirmation do
      sns_message_type "SubscriptionConfirmation"
    end

    factory :aws_sns_message_notification, :class => AwsSnsMessage::Notification do
      sns_message_type "Notification"
    end
  end

  factory :recording do
    association :phone_call

    trait :initiated do
      status "initiated"
    end

    trait :waiting_for_file do
      status "waiting_for_file"
    end

    trait :processing do
      status "processing"
    end
  end

  factory :phone_call_event_base, :class => PhoneCallEvent::Base do
    association :phone_call, :factory => [:phone_call, :initiated]

    factory :phone_call_event_ringing, :class => PhoneCallEvent::Ringing, :aliases => [:phone_call_event] do
    end

    factory :phone_call_event_answered, :class => PhoneCallEvent::Answered do
    end

    factory :phone_call_event_recording_started, :class => PhoneCallEvent::RecordingStarted do
    end

    factory :phone_call_event_recording_completed, :class => PhoneCallEvent::RecordingCompleted do
    end

    factory :phone_call_event_completed, :class => PhoneCallEvent::Completed do
      trait :busy do
        sip_term_status "486"
      end

      trait :not_answered do
        sip_term_status "480"
      end

      trait :failed do
        sip_term_status "404"
      end

      trait :answered do
        answer_epoch "1"
      end
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
        :phone_call, :account => evaluator.account, :external_id => evaluator.external_id
      )
    end

    trait :inbound do
      direction "inbound"
    end

    trait :outbound do
      direction "outbound"
    end

    trait :billable do
      bill_sec 1
      answer_time { Time.now }
    end

    trait :not_billable do
      bill_sec 0
      answer_time nil
    end

    trait :event_answered do
      billable
    end

    trait :event_not_answered do
      sip_term_status "480"
    end

    trait :event_busy do
      sip_term_status "486"
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
        :content_type => cdr.send(:content_type)
      )
    end
  end

  factory :account do |n|
    trait :with_access_token do
      after(:build) do |account|
        account.access_token ||= build(:access_token, :resource_owner_id => account.id)
      end
    end
  end

  factory :incoming_phone_number do
    account
    phone_number { generate(:phone_number) }
    voice_url "https://rapidpro.ngrok.com/handle/33/"

    trait :with_optional_attributes do
      with_voice_method
      with_status_callback_url
      with_status_callback_method
      with_twilio_request_phone_number
    end

    trait :with_twilio_request_phone_number do
      twilio_request_phone_number "123456789"
    end
  end

  factory :phone_call do
    account
    to "+85512334667"
    from     "2442"
    voice_url "https://rapidpro.ngrok.com/handle/33/"

    trait :from_account_with_access_token do
      association :account, :factory => [:account, :with_access_token]
    end

    trait :with_external_id do
      external_id { generate(:external_id) }
    end

    trait :queued do
      status "queued"
    end

    trait :initiated do
      status "initiated"
    end

    trait :answered do
      status "answered"
    end

    trait :not_answered do
      status "not_answered"
    end

    trait :ringing do
      status "ringing"
    end

    trait :canceled do
      status "canceled"
    end

    trait :failed do
      status "failed"
    end

    trait :completed do
      status "completed"
    end

    trait :busy do
      status "busy"
    end

    trait :can_complete do
      answered
    end

    trait :already_completed do
      failed
    end

    trait :with_optional_attributes do
      from_account_with_access_token
      with_voice_method
      with_status_callback_url
      with_status_callback_method
    end

    trait :initiating_inbound_call do
      initiating_inbound_call true
      incoming_phone_number
      to { incoming_phone_number.phone_number }
      with_external_id
    end
  end

  factory :access_token, :class => Doorkeeper::AccessToken
end

