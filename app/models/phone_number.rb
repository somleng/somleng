class PhoneNumber < ApplicationRecord
  belongs_to :carrier
  belongs_to :account, optional: true
  has_many :phone_calls
  has_one :configuration, class_name: "PhoneNumberConfiguration"

  def release!
    update!(
      account: nil,
      voice_url: nil,
      voice_method: nil,
      status_callback_url: nil,
      status_callback_method: nil,
      sip_domain: nil
    )
  end
end
