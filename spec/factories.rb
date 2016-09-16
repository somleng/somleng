FactoryGirl.define do
  sequence :somleng_call_id do |n|
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
  end

  factory :phone_call do
    account
    to "+85512334667"
    from     "2442"
    voice_url "https://rapidpro.ngrok.com/handle/33/"

    trait :from_account_with_access_token do
      association :account, :factory => [:account, :with_access_token]
    end

    trait :with_somleng_call_id do
      somleng_call_id { generate(:somleng_call_id) }
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
  end

  factory :access_token, :class => Doorkeeper::AccessToken
end

