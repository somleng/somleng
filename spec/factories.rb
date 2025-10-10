FactoryBot.define do
  sequence(:phone_number, "855972345678")
  sequence(:ip_address) { IPAddr.new(SecureRandom.random_number(2**32), Socket::AF_INET) }

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
    billing_currency { ISO3166::Country.new(country_code).currency_code }
    sequence(:subdomain) { |n| "at-t#{n}" }
    website { "https://at-t.com" }
    with_oauth_application

    trait :restricted do
      restricted { true }
    end

    trait :with_logo do
      association :logo, factory: :active_storage_attachment, filename: "carrier_logo.jpeg"
    end

    trait :with_favicon do
      transient do
        filename { "favicon-32x32.png" }
      end

      favicon { association(:active_storage_attachment, filename:) }
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
    transient do
      interactable { association :phone_call, to: generate(:phone_number) }
    end

    carrier { interactable.carrier }
    account { interactable.account }
    beneficiary_fingerprint { interactable.beneficiary_fingerprint }
    beneficiary_country_code { interactable.beneficiary_country_code }
    interactable_type { interactable.class.name }
  end

  factory :sip_trunk do
    carrier
    name { "My SIP trunk" }
    region { "hydrogen" }
    ip_address_authentication

    trait :ip_address_authentication do
      authentication_mode { :ip_address }
      inbound_source_ips { generate(:ip_address) }
      outbound_host { "sip.example.com" }
    end

    trait :client_credentials_authentication do
      authentication_mode { :client_credentials }
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

  factory :inbound_source_ip_address do
    ip { generate(:ip_address) }
    region { "hydrogen" }
  end

  factory :sip_trunk_inbound_source_ip_address do
    association :sip_trunk
    association :inbound_source_ip_address
    region { inbound_source_ip_address.region }
    ip { inbound_source_ip_address.ip }
  end

  factory :sms_gateway do
    name { "GoIP" }
    max_channels { 4 }
    carrier

    traits_for_enum :device_type, SMSGateway.device_type.values

    trait :connected do
      after(:create, &:receive_ping)
    end

    trait :disconnected do
      after(:create, &:disconnect!)
    end
  end

  factory :sms_gateway_channel_group do
    name { "Metfone" }
    sms_gateway
  end

  factory :sms_gateway_channel do
    sms_gateway { channel_group.sms_gateway }
    association :channel_group, factory: :sms_gateway_channel_group
    sequence(:slot_index)
  end

  factory :event do
    phone_call_completed

    trait :phone_call_completed do
      phone_call
      carrier { phone_call.carrier }
      type { "phone_call.completed" }
      details do
        phone_call.jsonapi_serializer_class.new(phone_call.decorated).as_json
      end
    end
  end

  factory :account do
    carrier
    enabled
    with_access_token
    name { "Rocket Rides" }
    default_tts_voice { "Basic.Kal" }
    billing_currency { carrier.billing_currency }
    traits_for_enum :type, %i[carrier_managed customer_managed]
    traits_for_enum :status, %w[enabled disabled]
    carrier_managed

    trait :customer_managed do
      type { :customer_managed }

      after(:build) do |account|
        account.account_memberships << create(:account_membership, :owner, account:, carrier: account.carrier) if account.account_memberships.empty?
      end
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

  factory :export do
    association :user, factory: %i[user carrier]
    resource_type { "PhoneCall" }
    scoped_to { { carrier_id: user.carrier.id } }
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
      pathname { nil }
    end

    initialize_with do
      ActiveStorage::Blob.create_and_upload!(
        io: pathname.present? ? pathname.open : File.open("#{RSpec.configuration.file_fixture_path}/#{filename}"),
        filename:
      )
    end
  end

  factory :phone_number do
    carrier

    trait :disabled do
      visibility { :disabled }
    end

    visibility { :private }

    trait :assigned do
      transient do
        account { build(:account, carrier:) }
      end

      after(:build) do |phone_number, evaluator|
        phone_number.active_plan ||= build(
          :phone_number_plan,
          account: evaluator.account,
          phone_number:
        )
      end
    end

    number { generate(:phone_number) }
    type { PhoneNumberType.new.cast(number).e164? ? :mobile : :short_code }
    iso_country_code { PhoneNumberType.new.cast(number).e164? ? nil : "KH" }
  end

  factory :incoming_phone_number do
    transient do
      type { :mobile }
      amount { Money.from_amount(1.15, "USD") }
      visibility { :private }
    end

    trait :active do
      status { :active }
    end

    trait :released do
      status { :released }
      released_at { Time.current }
    end

    status { :active }
    account_type { :customer_managed }
    account { association :account, type: account_type, billing_currency: amount.currency }
    carrier { account.carrier }
    number { generate(:phone_number) }
    friendly_name { PhoneNumberFormatter.new.format(PhoneNumberType.new.cast(number), format: :international) }
    phone_number { association :phone_number, carrier:, number:, type:, price: amount, visibility: }
    after(:build) do |incoming_phone_number|
      incoming_phone_number.account_type = incoming_phone_number.account.type
      incoming_phone_number.phone_number_plan ||= build(
        :phone_number_plan,
        status: incoming_phone_number.active? ? :active : :canceled,
        account: incoming_phone_number.account,
        number: incoming_phone_number.phone_number.number,
        phone_number: incoming_phone_number.phone_number,
        carrier: incoming_phone_number.carrier,
        amount: incoming_phone_number.phone_number.price
      )
    end

    trait :fully_configured do
      voice_url { "https://demo.twilio.com/docs/voice.xml" }
      status_callback_url { "https://example.com/status-callback" }
      sms_url { "https://demo.twilio.com/docs/messaging.xml" }
    end
  end

  factory :phone_call do
    account
    carrier { account.carrier }
    to { "85512334667" }
    from { "2442" }
    voice_url { "https://rapidpro.ngrok.com/handle/33/" }
    voice_method { "POST" }
    outbound
    region { "hydrogen" }
    external_id { SecureRandom.uuid }

    trait :routable do
      association :account, factory: %i[account with_sip_trunk]
    end

    trait :user_terminated do
      user_terminated_at { Time.current }
    end

    trait :user_updated do
      user_updated_at { Time.current }
    end

    trait :internal do
      internal { true }
    end

    trait :queued do
      external_id { nil }
      status { :queued }
    end

    trait :initiated do
      external_id { SecureRandom.uuid }
      call_service_host { "10.10.1.13" }
      initiated_at { Time.current }
      status { :initiated }
    end

    trait :answered do
      initiated
      status { :answered }
    end

    traits_for_enum :status, %i[initiating not_answered ringing canceled failed busy]

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
      direction { :outbound_api }

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

  factory :message do
    account
    carrier { account.carrier }
    sms_gateway { association :sms_gateway, carrier: account.carrier }
    to { "85512334667" }
    from { "2442" }
    direction { :outbound_api }
    body { "Hello World" }
    segments { 1 }
    encoding { "GSM" }

    trait :robot do
      inbound
      from { "732873" }
      to { "85512334667" }
    end

    trait :inbound do
      direction { :inbound }
      status { :received }
      received_at { Time.current }
      sms_url { "https://example.com/messaging.xml" }
      sms_method { "POST" }
    end

    trait :internal do
      internal { true }
    end

    trait :accepted do
      with_messaging_service
      status { :accepted }
      from { nil }
      accepted_at { Time.current }
    end

    trait :scheduled do
      with_messaging_service
      status { :scheduled }
      scheduled_at { Time.current }
      from { nil }
      send_at { 5.days.from_now }
    end

    trait :queued do
      status { :queued }
      queued_at { Time.current }
    end

    trait :sending do
      status { :sending }
      sending_at { Time.current }
    end

    trait :sent do
      sending
      with_send_request
      status { :sent }
      sent_at { Time.current }
    end

    trait :failed do
      sent
      status { :failed }
      failed_at { Time.current }
    end

    trait :delivered do
      sent
      status { :delivered }
      delivered_at { Time.current }
    end

    trait :with_messaging_service do
      messaging_service
      account { messaging_service.account }
    end

    trait :with_send_request do
      after(:build) do |message|
        message.send_request = build(:message_send_request, message:)
      end
    end
  end

  factory :message_send_request do
    message
    sms_gateway { message.sms_gateway }
  end

  factory :messaging_service do
    defer_to_sender
    account
    carrier { account.carrier }
    name { "My Messaging Service" }
    traits_for_enum :inbound_message_behavior, %w[defer_to_sender drop]

    trait :webhook do
      inbound_message_behavior { :webhook }
      inbound_request_url { "https://www.example.com/incoming_request.xml" }
      inbound_request_method { "POST" }
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
    inbound_message

    error_message { "Phone number 12513095500 does not exist" }

    traits_for_enum :type, %w[inbound_message inbound_call]
  end

  factory :tts_event do
    phone_call
    account { phone_call.account }
    carrier { account.carrier }
    tts_voice { "Basic.Kal" }
    tts_provider { "Basic" }
    tts_engine { "Standard" }
    num_chars { 100 }
  end

  factory :verification_service do
    account
    carrier { account.carrier }
    name { "My Verification Service" }
    code_length { 4 }
  end

  factory :verification do
    verification_service
    account { verification_service.account }
    carrier { verification_service.carrier }
    channel { "sms" }
    to { "85512334667" }
    code { "1234" }

    traits_for_enum :status, %w[pending canceled approved]

    trait :expired do
      status { :pending }
      expired_at { 1.minute.ago }
    end

    trait :too_many_check_attempts do
      after(:build) do |verification|
        verification.verification_attempts = build_list(:verification_attempt, 5, verification:)
      end
    end

    trait :too_many_delivery_attempts do
      after(:build) do |verification|
        verification.delivery_attempts = build_list(
          :verification_delivery_attempt, 5, verification:
        )
      end
    end
  end

  factory :verification_attempt do
    verification
    code { "9876" }

    trait :successful do
      verification { association :verification, :approved }
      code { verification.code }
    end
  end

  factory :verification_delivery_attempt do
    verification
    channel { verification.channel }
    to { verification.to }
    from { generate(:phone_number) }

    trait :sms do
      channel { :sms }
      message { association :message, to:, from:, account: verification.account, internal: true }
    end
  end

  factory :trial_interactions_credit_voucher do
    number_of_interactions { 500 }
    carrier { association :carrier, :restricted }
  end

  factory :error_log_notification do
    transient do
      carrier { build(:carrier) }
      account { nil }
      error_log_message { "error message" }
    end

    error_log { association :error_log, error_message: error_log_message, carrier:, account: }
    user { association :user, :carrier, carrier: error_log.carrier }
    message_digest { error_log.error_message }
    email { user.email }
  end

  factory :media_stream do
    phone_call
    inbound
    account { phone_call.account }
    url { "wss://example.com/audio" }
    traits_for_enum :status, %i[initialized connected started disconnected connect_failed]
    traits_for_enum :tracks, %i[inbound outbound both]
  end

  factory :media_stream_event do
    media_stream
    phone_call { media_stream.phone_call }
    traits_for_enum :type, %i[connect start disconnect connect_failed]
  end

  factory :phone_number_plan do
    transient do
      type { :mobile }
      account_type { :carrier_managed }
    end

    account { association :account, type: account_type }
    carrier { account.carrier }
    amount { Money.from_amount(1.15, account.billing_currency) }
    number { generate(:phone_number) }
    status { :active }
    phone_number { association :phone_number, carrier:, number:, type:, price: amount }

    after(:build) do |phone_number_plan, evaluator|
      phone_number_plan.incoming_phone_number ||= build(
        :incoming_phone_number,
        phone_number_plan:,
        account: phone_number_plan.account,
        phone_number: phone_number_plan.phone_number,
        account_type: evaluator.account_type
      )
    end

    trait :active do
      status { :active }
    end

    trait :canceled do
      status { :canceled }
      canceled_at { Time.current }
    end
  end

  factory :application_push_device do
    owner { association :sms_gateway, :app }
    token { SecureRandom.uuid }
    name { "Oppo A57" }
    platform { "google" }
  end
end
