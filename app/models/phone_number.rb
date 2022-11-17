class PhoneNumber < ApplicationRecord
  NUMBER_FORMAT = /\A\d+\z/

  belongs_to :carrier
  belongs_to :managing_carrier, class_name: "Carrier"
  belongs_to :account, optional: true
  has_many :phone_calls
  has_one :configuration, class_name: "PhoneNumberConfiguration"

  validates :number,
            presence: true,
            uniqueness: { scope: :carrier_id },
            format: { with: NUMBER_FORMAT, allow_blank: true }

  def release!
    transaction do
      update!(account: nil)
      configuration&.destroy!
    end
  end

  def may_release?
    account_id.present?
  end

  def assigned?
    account_id.present?
  end

  def configured?
    configuration.present?
  end
end
