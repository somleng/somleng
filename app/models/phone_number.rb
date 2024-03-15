class PhoneNumber < ApplicationRecord
  NUMBER_FORMAT = /\A\d+\z/

  belongs_to :carrier
  belongs_to :account, optional: true
  has_many :phone_calls
  has_many :messages
  has_one :configuration, class_name: "PhoneNumberConfiguration"

  delegate :configured?, to: :configuration, allow_nil: true

  validates :number,
            presence: true,
            uniqueness: { scope: :carrier_id },
            format: { with: NUMBER_FORMAT, allow_blank: true }

  class << self
    def enabled
      where(enabled: true)
    end

    def utilized
      scope = left_joins(:phone_calls).left_joins(:messages)
      .where.not(phone_calls: { phone_number_id: nil }).or(where.not(messages: { phone_number_id: nil }))
      .distinct

      where(id: scope.select(:id))
    end

    def unutilized
      left_joins(:phone_calls).left_joins(:messages)
      .where(phone_calls: { phone_number_id: nil }, messages: { phone_number_id: nil })
    end

    def configured
      joins(:configuration).merge(PhoneNumberConfiguration.configured)
    end

    def unconfigured
      left_joins(:configuration).merge(PhoneNumberConfiguration.unconfigured)
    end
  end

  def release!
    transaction do
      update!(account: nil)
      configuration&.destroy!
    end
  end

  def assigned?
    account_id.present?
  end

  def utilized?
    phone_calls.any? || messages.any?
  end
end
