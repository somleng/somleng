class PhoneNumberForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  attribute :carrier
  attribute :number, PhoneNumberType.new
  attribute :account_id
  attribute :enabled, default: true
  attribute :phone_number, default: -> { PhoneNumber.new }
  attribute :type
  attribute :country
  attribute :price, :decimal, default: 0.0
  attribute :country_assignment_rules, default: -> { PhoneNumberCountryAssignmentRules.new }

  with_options if: :new_record? do
    validates :number, presence: true
    validates :number, format: PhoneNumber::NUMBER_FORMAT, allow_blank: true
    validate :validate_number
  end

  validates :type, phone_number_type: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  validate :validate_country

  delegate :persisted?, :new_record?, :id, :assigned?, to: :phone_number

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneNumber")
  end

  def self.initialize_with(phone_number)
    new(
      phone_number:,
      account_id: phone_number.account_id,
      carrier: phone_number.carrier,
      number: phone_number.decorated.number_formatted,
      enabled: phone_number.enabled,
      country: phone_number.iso_country_code,
      type: phone_number.type,
      price: phone_number.price
    )
  end

  def save
    return false if invalid?

    phone_number.carrier = carrier
    phone_number.enabled = enabled
    phone_number.number = number if new_record?
    phone_number.type = type
    phone_number.iso_country_code = country
    phone_number.price = Money.from_amount(price, carrier.billing_currency)
    phone_number.account ||= carrier.accounts.find(account_id) if account_id.present?

    phone_number.save!
  end

  def account_options_for_select
    carrier.accounts.map { |account| [ account.name, account.id ] }
  end

  def possible_countries
    return ISO3166::Country.all.map(&:alpha2) if new_record?

    parsed_phone_number.possible_countries.map(&:alpha2)
  end

  private

  def validate_number
    return if errors[:number].any?
    return unless carrier.phone_numbers.exists?(number:)

    errors.add(:number, :taken)
  end

  def validate_country
    return if number.blank?

    self.country = country_assignment_rules.country_for(
      number:,
      preferred_country: ISO3166::Country.new(country),
      fallback_country: carrier.country,
      existing_country: phone_number.country
    )&.alpha2

    errors.add(:country, :invalid) if country.blank?
  end

  def parsed_phone_number
    @parsed_phone_number ||= country_assignment_rules.phone_number_parser.parse(number)
  end
end
