class PhoneNumber < ApplicationRecord
  self.inheritance_column = :_type_disabled

  NUMBER_FORMAT = /\A\d+\z/
  SHORT_CODE_TYPES = [ :short_code ].freeze
  E164_TYPES = [ :local, :mobile, :toll_free ].freeze
  TYPES = (SHORT_CODE_TYPES + E164_TYPES).freeze

  extend Enumerize

  enumerize :type, in: TYPES
  monetize :price_cents, with_model_currency: :currency, numericality: {
    greater_than_or_equal_to: 0
  }

  before_validation :set_defaults, on: :create

  attribute :currency, CurrencyType.new
  attribute :number, PhoneNumberType.new

  belongs_to :carrier
  has_many :phone_calls
  has_many :messages
  has_one :active_plan, -> { active }, class_name: "PhoneNumberPlan", dependent: :restrict_with_error
  has_one :account, through: :active_plan
  has_many :plans, class_name: "PhoneNumberPlan"

  validates :number,
            presence: true,
            uniqueness: { scope: :carrier_id },
            format: { with: NUMBER_FORMAT, allow_blank: true }

  validates :iso_country_code, phone_number_country: true
  validates :type, phone_number_type: true

  class << self
    def available
      enabled.unassigned
    end

    def assigned
      joins(:active_plan)
    end

    def unassigned
      where.not(id: assigned.select(:id))
    end

    def enabled
      where(enabled: true)
    end

    def supported_countries
      select(:iso_country_code).distinct.order(:iso_country_code)
    end

    def supported_currencies
      select(:currency).distinct.order(:currency)
    end
  end

  def country
    ISO3166::Country.new(iso_country_code)
  end

  def assigned?
    active_plan.present?
  end

  private

  def set_defaults
    return if carrier.blank?
    return if number.blank?

    self.currency ||= carrier.billing_currency
    self.price ||= Money.new(0, currency)

    self.iso_country_code ||= (number.e164? ? ResolvePhoneNumberCountry.call(number, fallback_country: carrier.country) : carrier.country).alpha2
  end
end
