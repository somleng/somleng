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
    association :file, factory: :active_storage_attachment, filename: "freeswitch_cdr.json"
    call_leg { "A" }

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

    duration_sec { 5 }
    bill_sec { 5 }
    direction { "outbound" }
    hangup_cause { "ORIGINATOR_CANCEL" }
    start_time { 10.seconds.ago }
    end_time { 5.seconds.ago }
  end

  factory :carrier do
    name { "AT&T" }
    country_code { "KH" }
    sequence(:subdomain) { |n| "at-t#{n}" }
    website { "https://at-t.com" }
    with_oauth_application

    trait :restricted do
      restricted { true }
    end

    trait :with_logo do
      association :logo, factory: :active_storage_attachment, filename: "carrier_logo.jpeg"
    end

    trait :with_oauth_application do
      after(:build) do |carrier|
        carrier.oauth_application ||= build(:oauth_application, owner: carrier)
        carrier.oauth_application.access_tokens << build(
          :oauth_access_token,
          application: carrier.oauth_application,
          scopes: :carrier_api
        )
      end
    end
  end

  factory :interaction do
    carrier { interactable.carrier }
    account { interactable.account }
    for_phone_call

    trait :for_phone_call do
      interactable { association :phone_call, to: generate(:phone_number) }
      beneficiary_fingerprint { interactable.beneficiary_fingerprint }
      beneficiary_country_code { interactable.beneficiary_country_code }
    end
  end

  factory :sip_trunk do
    carrier
    name { "My SIP trunk" }
    ip_address_authentication

    trait :ip_address_authentication do
      authentication_mode { :ip_address }
      inbound_source_ip { IPAddr.new(SecureRandom.random_number(2**32), Socket::AF_INET) }
      outbound_host { "sip.example.com" }
    end

    trait :client_credentials_authentication do
      authentication_mode { :client_credentials }
      inbound_source_ip { nil }
      outbound_host { nil }
      outbound_plus_prefix { true }
    end

    trait :busy do
      max_channels { 1 }
      after(:build) do |sip_trunk|
        sip_trunk.phone_calls << build(
          :phone_call, :initiated, sip_trunk:, carrier: sip_trunk.carrier
        )
      end
    end
  end

  factory :sms_gateway do
    name { "GoIP" }
    max_channels { 4 }
    carrier
  end

  factory :sms_gateway_channel_group do
    name { "Metfone" }
    sms_gateway
  end

  factory :sms_gateway_channel do
    sms_gateway { channel_group.sms_gateway }
    channel_group
    sequence(:slot_index)
  end

  factory :event do
    phone_call_completed

    trait :phone_call_completed do
      association :eventable, factory: :phone_call
      type { "phone_call.completed" }
    end

    carrier { eventable.carrier }

    details do
      eventable.jsonapi_serializer_class.new(eventable.decorated).as_json
    end
  end

  factory :account do
    name { "Rocket Rides" }
    enabled
    with_access_token
    association :carrier
    traits_for_enum :status, %w[enabled disabled]

    trait :carrier_managed do
      with_access_token
    end

    trait :with_access_token do
      after(:build) do |account|
        account.access_token ||= build(:oauth_access_token, resource_owner_id: account.id)
      end
    end

    trait :with_sip_trunk do
      sip_trunk { build(:sip_trunk, carrier:) }
    end
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "John Doe" }
    password { "super secret password" }
    otp_required_for_login { true }
    confirmed
    carrier

    traits_for_enum :carrier_role, %i[owner admin member]

    trait :carrier do
      admin
    end

    trait :invited do
      invitation_sent_at { Time.current }
      invitation_token { SecureRandom.urlsafe_base64 }
    end

    trait :invitation_accepted do
      invited
      invitation_accepted_at { Time.current }
    end

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :otp_required_for_login do
      otp_required_for_login { true }
    end

    trait :with_account_membership do
      transient do
        account_role { :owner }
        account { build(:account, carrier:) }
      end

      after(:build) do |user, evaluator|
        account_membership = build(
          :account_membership,
          user:,
          account: evaluator.account,
          role: evaluator.account_role
        )
        user.account_memberships << account_membership
        user.current_account_membership = account_membership
      end
    end
  end

  factory :account_membership do
    transient do
      carrier { build(:carrier) }
    end

    account { association :account, carrier: }
    user { association :user, carrier: }
    admin

    traits_for_enum :role, %i[owner admin member]

    after(:stub) do |account_membership|
      account_membership.user.current_account_membership ||= account_membership
    end

    after(:build) do |account_membership|
      account_membership.user.current_account_membership ||= account_membership
    end
  end

  factory :import do
    phone_numbers
    association :user, factory: %i[user carrier]
    carrier { user.carrier }

    trait :phone_numbers do
      resource_type { "PhoneNumber" }

      association :file, factory: :active_storage_attachment, filename: "phone_numbers.csv"
    end
  end

  factory :active_storage_attachment, class: "ActiveStorage::Blob" do
    transient do
      filename { "phone_numbers.csv" }
    end

    initialize_with do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open("#{RSpec.configuration.file_fixture_path}/#{filename}"),
        filename:
      )
    end
  end

  factory :phone_number do
    carrier

    trait :assigned_to_account do
      account { association :account, carrier: }
    end

    trait :disabled do
      enabled { false }
    end

    trait :configured do
      assigned_to_account

      after(:build) do |phone_number|
        phone_number.configuration ||= build(
          :phone_number_configuration, phone_number:
        )
      end
    end

    number { generate(:phone_number) }
  end

  factory :phone_number_configuration do
    phone_number

    voice_url { "https://demo.twilio.com/docs/voice.xml" }
    voice_method { "GET" }
    status_callback_url { "https://example.com/status-callback" }
    status_callback_method { "POST" }
  end

  factory :phone_call do
    account
    carrier { account.carrier }
    to { "85512334667" }
    from { "2442" }
    voice_url { "https://rapidpro.ngrok.com/handle/33/" }
    voice_method { "POST" }
    outbound
    external_id { SecureRandom.uuid }

    trait :routable do
      association :account, factory: %i[account with_sip_trunk]
    end

    trait :queued do
      external_id { nil }
      status { :queued }
    end

    trait :initiated do
      external_id { SecureRandom.uuid }
      initiated_at { Time.current }
      status { :initiated }
    end

    traits_for_enum :status, %i[initiating answered not_answered ringing canceled failed busy]

    trait :inbound do
      direction { :inbound }

      after(:build) do |phone_call|
        phone_call.sip_trunk ||= build(:sip_trunk, carrier: phone_call.carrier)
        phone_call.phone_number ||= build(
          :phone_number, number: phone_call.to, carrier: phone_call.carrier
        )
      end
    end

    trait :outbound do
      direction { :outbound }

      after(:build) do |phone_call|
        phone_call.sip_trunk ||= build(:sip_trunk, carrier: phone_call.carrier)
      end
    end

    trait :completed do
      status { :completed }

      after(:build) do |phone_call|
        phone_call.call_data_record ||= build(:call_data_record, phone_call:)
      end
    end
  end

  factory :oauth_access_token, class: "Doorkeeper::AccessToken" do
    trait :expired do
      expires_in { 1 }
      created_at { 5.minutes.ago }
    end

    trait :with_refresh_token do
      refresh_token { SecureRandom.urlsafe_base64 }
    end
  end

  factory :oauth_application do
    name { "My Application" }
    redirect_uri { "urn:ietf:wg:oauth:2.0:oob" }

    trait :carrier do
      association :owner, factory: :carrier
      scopes { "carrier_api" }
    end
  end

  factory :webhook_endpoint do
    association :oauth_application, factory: %i[oauth_application carrier]
    url { "https://somleng-carrier.free.beeceptor.com" }
  end

  factory :webhook_request_log do
    carrier { event.carrier }
    event
    webhook_endpoint
    url { webhook_endpoint.url }
    failed { false }
    http_status_code { "200" }

    trait :failed do
      failed { true }
      http_status_code { "500" }
    end
  end

  factory :recording do
    phone_call
    account { phone_call.account }
    external_id { SecureRandom.uuid }
    in_progress

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }

      association :file, factory: :active_storage_attachment, filename: "recording.wav"
      association :mp3_file, factory: :active_storage_attachment, filename: "recording.mp3"
    end
  end

  factory :error_log do
    error_message { "error message" }
  end
end
