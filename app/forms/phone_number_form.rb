class PhoneNumberForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  attribute :carrier
  attribute :number
  attribute :account_id
  attribute :enabled, default: true
  attribute :phone_number, default: -> { PhoneNumber.new }
  attribute :sip_trunk_id
  attribute :sms_gateway_id

  with_options if: :new_record? do
    validates :number, presence: true
    validates :number, format: PhoneNumber::NUMBER_FORMAT, allow_blank: true
    validate :validate_number
  end

  delegate :persisted?, :new_record?, :id, :assigned?, to: :phone_number

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneNumber")
  end

  def self.initialize_with(phone_number)
    new(
      phone_number:,
      account_id: phone_number.account_id,
      sip_trunk_id: phone_number.sip_trunk_id,
      sms_gateway_id: phone_number.sms_gateway_id,
      carrier: phone_number.carrier,
      number: phone_number.decorated.number_formatted,
      enabled: phone_number.enabled
    )
  end

  def save
    return false if invalid?

    phone_number.carrier = carrier
    phone_number.enabled = enabled
    phone_number.number = number if new_record?
    phone_number.account ||= carrier.accounts.find(account_id) if account_id.present?
    phone_number.sip_trunk ||= carrier.sip_trunks.find(sip_trunk_id) if sip_trunk_id.present?
    phone_number.sms_gateway ||= carrier.sms_gateways.find(sms_gateway_id) if sms_gateway_id.present?

    phone_number.save!
  end

  def account_options_for_select
    carrier.accounts.map { |account| [account.name, account.id] }
  end

  def sip_trunk_options_for_select
    carrier.sip_trunks.map { |sip_trunk| [sip_trunk.name, sip_trunk.id] }
  end

  def sms_gateway_options_for_select
    carrier.sms_gateways.map { |sms_gateway| [sms_gateway.name, sms_gateway.id] }
  end

  private

  def validate_number
    return if errors[:number].any?
    return unless carrier.phone_numbers.exists?(number:)

    errors.add(:number, :taken)
  end
end
