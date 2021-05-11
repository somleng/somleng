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

  factory :call_data_record do
    transient do
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

    duration_sec { 5 }
    bill_sec { 5 }
    direction { "outbound" }
    hangup_cause { "ORIGINATOR_CANCEL" }
    start_time { 10.seconds.ago }
    end_time { 5.seconds.ago }
  end

  factory :carrier do
    name { "Somleng" }
  end

  factory :outbound_sip_trunk do
    carrier
    name { "My SIP trunk" }
    host { "host.docker.internal:5061" }
  end

  factory :account do
    enabled
    with_access_token
    carrier
    traits_for_enum :status, %w[enabled disabled]

    trait :with_access_token do
      after(:build) do |account|
        account.access_token ||= build(:access_token, resource_owner_id: account.id)
      end
    end
  end

  factory :incoming_phone_number do
    account
    phone_number { generate(:phone_number) }
    voice_method { "POST" }
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
    to { "85512334667" }
    from { "2442" }
    voice_url { "https://rapidpro.ngrok.com/handle/33/" }
    voice_method { "POST" }
    outbound

    trait :inbound do
      with_external_id
      direction { :inbound }
    end

    trait :outbound do
      direction { :outbound }
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

  factory :access_token, class: "Doorkeeper::AccessToken"
end
