class IncomingPhoneNumber < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  belongs_to :phone_number_plan
  belongs_to :account
  belongs_to :phone_number, optional: true
  belongs_to :messaging_service, optional: true

  has_many :phone_calls
  has_many :messages

  enumerize :voice_method, in: %w[POST GET], default: "POST"
  enumerize :sms_method, in: %w[POST GET], default: "POST"
  enumerize :status_callback_method, in: %w[POST GET], default: "POST"
  enumerize :status, in: %w[active released], default: :active, scope: :shallow, predicates: true
  enumerize :account_type, in: Account.type.values, scope: :shallow

  attribute :number, PhoneNumberType.new

  delegate :country, :type, to: :phone_number, allow_nil: true

  def release!
    transaction do
      update!(status: :released)
      phone_number_plan.cancel!
    end
  end
end
