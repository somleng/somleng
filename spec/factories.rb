FactoryBot.define do
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

  factory :freeswitch_cdr, class: CDR::Freeswitch do
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

  factory :call_data_record do
    transient do
      cdr { build(:freeswitch_cdr) }
      account { build(:account) }
      external_id { SecureRandom.uuid }
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

    trait :with_optional_attributes do
      with_voice_method
      with_status_callback_url
      with_status_callback_method
      with_twilio_request_phone_number
    end

    trait :with_twilio_request_phone_number do
      twilio_request_phone_number { "123456789" }
    end
  end

  factory :phone_call do
    account
    to { "+85512334667" }
    from { "2442" }
    voice_url { "https://rapidpro.ngrok.com/handle/33/" }

    trait :inbound do
      with_external_id
    end

    trait :with_external_id do
      external_id { SecureRandom.uuid }
    end

    trait :queued do
      status { PhoneCall::STATE_QUEUED }
    end

    trait :initiated do
      with_external_id
      status { PhoneCall::STATE_INITIATED }
    end

    trait :answered do
      with_external_id
      status { PhoneCall::STATE_ANSWERED }
    end

    trait :not_answered do
      with_external_id
      status { PhoneCall::STATE_NOT_ANSWERED }
    end

    trait :ringing do
      with_external_id
      status { PhoneCall::STATE_RINGING }
    end

    trait :canceled do
      with_external_id
      status { PhoneCall::STATE_CANCELED }
    end

    trait :failed do
      with_external_id
      status { PhoneCall::STATE_FAILED }
    end

    trait :completed do
      with_external_id
      status { PhoneCall::STATE_COMPLETED }
    end

    trait :busy do
      with_external_id
      status { PhoneCall::STATE_BUSY }
    end

    trait :can_complete do
      answered
    end

    trait :already_completed do
      failed
    end

    trait :with_optional_attributes do
      with_voice_method
      with_status_callback_url
      with_status_callback_method
    end
  end

  factory :access_token, class: Doorkeeper::AccessToken
end
