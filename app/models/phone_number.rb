class PhoneNumber < ApplicationRecord
  belongs_to :carrier
  belongs_to :account, optional: true
  has_many :phone_calls, dependent: :restrict_with_error
  has_one :configuration, class_name: "PhoneNumberConfiguration"

  def release!
    PhoneNumber.transaction do
      update!(account: nil)
      configuration&.destroy!
    end
  end
end
