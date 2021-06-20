class PhoneNumberForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  NUMBER_FORMAT = /\A\d+\z/.freeze

  attribute :carrier
  attribute :number
  attribute :account_id
  attribute :phone_number, default: -> { PhoneNumber.new }

  validates :number, presence: true
  validates :number, format: NUMBER_FORMAT, allow_nil: true, allow_blank: true
  validate :validate_number

  delegate :persisted?, :new_record?, :id, to: :phone_number

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneNumber")
  end

  def self.initialize_with(phone_number)
    new(
      phone_number: phone_number,
      account_id: phone_number.account_id,
      carrier: phone_number.carrier,
      number: phone_number.number
    )
  end

  def save
    return false if invalid?

    phone_number.carrier = carrier
    phone_number.number = number
    phone_number.account = account_id.present? ? carrier.accounts.find(account_id) : nil

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
    return if phone_number.number == number
    return unless carrier.phone_numbers.exists?(number: number)

    errors.add(:number, :taken)
  end
end
