class PhoneNumberForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  VISIBILITIES = {
    private: "Private <div class='form-text'>Only available for private use within your organization.</div>",
    public: "Public <div class='form-text'>Available for private use within your organization and purchasable by your customers.</div>",
    disabled: "Disabled <div class='form-text'>Disable this phone number.</div>"
  }.freeze

  enumerize :visibility, in: PhoneNumber.visibility.values, default: :private

  attribute :carrier
  attribute :number, PhoneNumberType.new
  attribute :phone_number, default: -> { PhoneNumber.new }
  attribute :type
  attribute :country
  attribute :region
  attribute :locality
  attribute :price, :decimal, default: 0.0
  attribute :visibility
  attribute :account_id

  with_options if: :new_record? do
    validates :number, presence: true
    validates :number, format: PhoneNumber::NUMBER_FORMAT, allow_blank: true
    validate :validate_number
  end

  validates :type, phone_number_type: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :country, phone_number_country: true, allow_blank: true
  validates :region, country_subdivision: { country_attribute: :country, country_code: ->(record) { record.country } }, allow_blank: true

  delegate :persisted?, :new_record?, :id, to: :phone_number

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneNumber")
  end

  def self.initialize_with(phone_number)
    new(
      phone_number:,
      carrier: phone_number.carrier,
      number: phone_number.decorated.number_formatted,
      country: phone_number.iso_country_code,
      region: phone_number.iso_region_code,
      locality: phone_number.locality,
      type: phone_number.type,
      price: phone_number.price,
      visibility: phone_number.visibility
    )
  end

  def save
    return false if invalid?

    phone_number.carrier = carrier
    phone_number.number = number if new_record?
    phone_number.visibility = visibility
    phone_number.type = type
    phone_number.iso_country_code = country if country.present?
    phone_number.iso_region_code = region.presence
    phone_number.locality = locality.presence
    phone_number.price = Money.from_amount(price, carrier.billing_currency)

    PhoneNumber.transaction do
      phone_number.save!
      create_plan!
      phone_number
    end
  end

  def possible_countries
    return ISO3166::Country.all.map(&:alpha2) if new_record?

    number.possible_countries.map(&:alpha2)
  end

  def visibility_options_for_select
    VISIBILITIES.map { |k, v| [ v.html_safe, k ] }
  end

  def account_options_for_select
    accounts_scope.map { |account| [ account.name, account.id ] }
  end

  def create_plan!
    return if account_id.blank?
    account = accounts_scope.find(account_id)

    CreatePhoneNumberPlan.call(
      phone_number:,
      account:,
      amount: Money.from_amount(0, carrier.billing_currency)
    )
  end

  private

  def validate_number
    return if errors[:number].any?
    return unless carrier.phone_numbers.exists?(number:)

    errors.add(:number, :taken)
  end

  def accounts_scope
    carrier.managed_accounts
  end
end
