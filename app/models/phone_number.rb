class PhoneNumber < ApplicationRecord
  belongs_to :carrier
  belongs_to :account, optional: true
  has_many :phone_calls, dependent: :restrict_with_error
  has_one :configuration, class_name: "PhoneNumberConfiguration"

  def self.assigned
    where.not(account_id: nil)
  end

  def self.configured
    left_outer_joins(:configuration).where.not(
      phone_number_configurations: { phone_number_id: nil }
    )
  end

  def release!
    PhoneNumber.transaction do
      update!(account: nil)
      configuration&.destroy!
    end
  end

  def configured?
    configuration.present?
  end
end
