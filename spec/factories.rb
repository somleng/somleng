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

