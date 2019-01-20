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

    twiml_instructions do
      twiml_instructions = {}
      twiml_instructions["recordingStatusCallback"] = status_callback_url if status_callback_url
      twiml_instructions["recordingStatusCallbackMethod"] = status_callback_method if status_callback_method
      twiml_instructions
    end
  end

  factory :call_data_record do
    phone_call
    inbound

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

    duration_sec { 25 }
    bill_sec { 20 }
    hangup_cause { "ORIGINATOR_CANCEL" }
    start_time { 1.minute.ago }
    end_time { Time.now  }
    price { Money.new(0) }

    file { Pathname(ActiveSupport::TestCase.fixture_path).join("files", "freeswitch_cdr.json").read }
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
      type { :completed }
      answer_epoch { "1" }
    end

    trait :not_answered do
      type { :completed }
      sip_term_status { "480" }
    end

    trait :busy do
      type { :completed }
      sip_term_status { "486" }
    end

    trait :completed do
      type { :completed }
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
