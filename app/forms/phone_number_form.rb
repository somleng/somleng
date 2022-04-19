class PhoneNumberForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  attribute :carrier
  attribute :number
  attribute :account_id
  attribute :enabled, default: true
  attribute :phone_number, default: -> { PhoneNumber.new }

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
      carrier: phone_number.carrier,
      number: phone_number.number,
      enabled: phone_number.enabled
    )
  end

  def save
    return false if invalid?

    phone_number.carrier = carrier
    phone_number.enabled = enabled
    phone_number.number = number if new_record?
    phone_number.account ||= carrier.accounts.find(account_id) if account_id.present?

    phone_number.save!
  end

  def account_options_for_select
    carrier.accounts.map do |account|
      {
        id: account.id,
        text: account.name
      }
    end
  end

  private

  def validate_number
    return if errors[:number].any?
    return unless carrier.phone_numbers.exists?(number:)

    errors.add(:number, :taken)
  end
end
