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
    country_code { "KH" }
  end

  factory :outbound_sip_trunk do
    carrier
    name { "My SIP trunk" }
    host { "sip.example.com" }
  end

  factory :account do
    name { "Rocket Rides" }
    enabled
    with_access_token
    association :carrier
    traits_for_enum :status, %w[enabled disabled]

    trait :with_access_token do
      after(:build) do |account|
        account.access_token ||= build(:access_token, resource_owner_id: account.id)
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
    account
    phone_number { generate(:phone_number) }
    voice_method { "POST" }
    voice_url { "https://rapidpro.ngrok.com/handle/33/" }

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
    external_id { SecureRandom.uuid }

    trait :routable do
      association :account, factory: %i[account with_outbound_sip_trunk]
    end

    trait :queued do
      external_id { nil }
      status { :queued }
    end

    traits_for_enum :status, %i[initiated answered not_answered ringing canceled failed completed busy]
    traits_for_enum :direction, %i[inbound outbound]
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

  factory :access_token, class: "Doorkeeper::AccessToken"
end
