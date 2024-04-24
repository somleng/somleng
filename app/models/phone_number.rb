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
  has_one :configuration, class_name: "PhoneNumberConfiguration"
  has_one :active_plan, -> { active }, class_name: "PhoneNumberPlan"
  has_one :account, through: :active_plan
  has_many :plans, class_name: "PhoneNumberPlan"

  delegate :configured?, to: :configuration, allow_nil: true

  validates :number,
            presence: true,
            uniqueness: { scope: :carrier_id },
            format: { with: NUMBER_FORMAT, allow_blank: true }

  validates :iso_country_code, phone_number_country: true
  validates :type, phone_number_type: true

  class << self
    def scoped_to(scope)
      if scope.key?(:account_id)
        assigned.where(phone_number_plans: { account_id: scope.fetch(:account_id) })
      else
        super
      end
    end

    def available
      enabled.unassigned
    end

    def assigned
      joins(:active_plan)
    end

    def unassigned
      left_joins(:active_plan).where(phone_number_plans: { phone_number_id: nil })
    end

    def enabled
      where(enabled: true)
    end

    def supported_countries
      select(:iso_country_code).distinct.order(:iso_country_code)
    end

    def utilized
      scope = assigned.left_joins(account: :phone_calls).left_joins(account: :messages)
              .where.not(phone_calls: { phone_number_id: nil }).or(where.not(messages: { phone_number_id: nil }))
              .distinct

      where(id: scope.select(:id))
    end

    def unutilized
      assigned_unutilized = assigned.left_joins(account: :phone_calls).left_joins(account: :messages)
                            .where(phone_calls: { phone_number_id: nil }, messages: { phone_number_id: nil })

      unassigned.or(where(id: assigned_unutilized.select(:id)))
    end

    def configured
      joins(:configuration).merge(PhoneNumberConfiguration.configured)
    end

    def unconfigured
      left_joins(:configuration).merge(PhoneNumberConfiguration.unconfigured)
    end

    def release_all
      find_each(&:release!)
    end
  end

  def country
    ISO3166::Country.new(iso_country_code)
  end

  def release!(...)
    transaction do
      active_plan.cancel!(...)
      configuration&.destroy!
    end
  end

  def assigned?
    account.present?
  end

  def utilized?
    return unless assigned?

    account.phone_calls.where(phone_number_id: id).any? || account.messages.where(phone_number_id: id).any?
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
