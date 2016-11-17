FactoryGirl.define do
  sequence :external_id do |n|
    "#{n}"
  end

  sequence :phone_number, 855972345678 do |n|
    n.to_s
  end

  trait :with_normalized_voice_method do
    voice_method "GET"
  end

  trait :with_denormalized_voice_method do
    voice_method "get"
  end

  trait :with_status_callback_url do
    status_callback_url "https://rapidpro.ngrok.com/handle/33/"
  end

  trait :with_status_callback_method do
    status_callback_method "POST"
  end

  factory :freeswitch_cdr, :class => CDR::Freeswitch do
    skip_create
    initialize_with { new(File.read(ActiveSupport::TestCase.fixture_path + "/freeswitch_cdr.json")) }
  end

  factory :usage_record, :class => Usage::Record do
    skip_create
    account
    category "calls"
    start_date "2012-09-01"
    end_date "2012-09-30"
  end

  factory :call_data_record do
    transient do
      cdr { build(:freeswitch_cdr) }
    end

    after(:build) do |call_data_record, evaluator|
      call_data_record.phone_call ||= build(:phone_call, :external_id => evaluator.cdr.uuid)
    end

    trait :inbound do
      direction "inbound"
    end

    trait :outbound do
      direction "outbound"
    end

    duration_sec { cdr.duration_sec }
    bill_sec { cdr.bill_sec }
    direction { cdr.direction }
    hangup_cause { cdr.hangup_cause }
    start_time { Time.at(cdr.start_epoch.to_i) }
    end_time { Time.at(cdr.end_epoch.to_i) }

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
      with_normalized_voice_method
      with_status_callback_url
      with_status_callback_method
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

    trait :with_optional_attributes do
      from_account_with_access_token
      with_normalized_voice_method
      with_status_callback_url
      with_status_callback_method
    end

    trait :inbound do
      inbound true
      incoming_phone_number
      to { incoming_phone_number.phone_number }
      with_external_id
    end
  end

  factory :access_token, :class => Doorkeeper::AccessToken
end

