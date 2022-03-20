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

    file do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open("#{RSpec.configuration.file_fixture_path}/freeswitch_cdr.json"),
        filename: external_id
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
    name { "Somleng" }
    country_code { "KH" }

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

  factory :outbound_sip_trunk do
    carrier
    name { "My SIP trunk" }
    host { "sip.example.com" }
  end

  factory :inbound_sip_trunk do
    carrier
    name { "My SIP trunk" }
    source_ip { IPAddr.new(SecureRandom.random_number(2**32), Socket::AF_INET) }
  end

  factory :event do
    carrier { eventable.carrier }
    association :eventable, factory: :phone_call
    type { "phone_call.completed" }
    details {
      eventable.jsonapi_serializer_class.new(eventable.decorated).as_json
    }
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

    trait :customer_managed do
      with_access_token

      after(:build) do |account|
        if account.account_memberships.empty?
          account.account_memberships << build(:account_membership,
                                               account: account)
        end
      end
    end

    trait :with_access_token do
      after(:build) do |account|
        account.access_token ||= build(:oauth_access_token, resource_owner_id: account.id)
      end
    end

    trait :with_outbound_sip_trunk do
      outbound_sip_trunk { build(:outbound_sip_trunk, carrier: carrier) }
    end
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "John Doe" }
    password { "super secret password" }
    otp_required_for_login { true }
    confirmed

    traits_for_enum :carrier_role, %i[owner admin member]

    trait :carrier do
      carrier
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
        account { build(:account) }
      end

      after(:build) do |user, evaluator|
        account_membership = build(
          :account_membership,
          user: user,
          account: evaluator.account,
          role: evaluator.account_role
        )
        user.account_memberships << account_membership
        user.current_account_membership = account_membership
      end
    end
  end

  factory :account_membership do
    user
    account
    admin

    traits_for_enum :role, %i[owner admin member]
  end

  factory :phone_number do
    carrier

    trait :assigned_to_account do
      account
    end

    number { generate(:phone_number) }
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
      association :account, factory: %i[account with_outbound_sip_trunk]
    end

    trait :queued do
      external_id { nil }
      status { :queued }
    end

    traits_for_enum :status, %i[initiated answered not_answered ringing canceled failed busy]

    trait :inbound do
      direction { :inbound }

      after(:build) do |phone_call|
        phone_call.inbound_sip_trunk ||= build(:inbound_sip_trunk, carrier: phone_call.carrier)
      end
    end

    trait :outbound do
      direction { :outbound }

      after(:build) do |phone_call|
        phone_call.outbound_sip_trunk ||= build(:outbound_sip_trunk, carrier: phone_call.carrier)
        phone_call.dial_string ||= "#{phone_call.to}@#{phone_call.outbound_sip_trunk.host}"
      end
    end

    trait :completed do
      status { :completed }

      after(:build) do |phone_call|
        phone_call.call_data_record ||= build(:call_data_record, phone_call: phone_call)
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

  factory :user_context do
    user
    association :current_organization, factory: :organization
    association :current_account_membership, factory: :account_membership

    initialize_with { new(user, current_organization, current_account_membership) }
  end

  factory :organization, class: "UserAuthorization::Organization" do
    transient do
      organization { build(:account) }
    end

    initialize_with { new(organization) }
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
      duration { 5 }
    end
  end
end
