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
    aws_sns_message_id { SecureRandom.uuid }

    factory :aws_sns_message_subscription_confirmation, :class => AwsSnsMessage::SubscriptionConfirmation do
    end

    factory :aws_sns_message_notification, :class => AwsSnsMessage::Notification do
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

