class AlphanumericSenderIDForm < ApplicationForm
  attribute :carrier
  attribute :account
  attribute :account_id
  attribute :sender_id, SquishedStringType.new
  attribute :resource, default: -> { AlphanumericSenderID.new }

  delegate :new_record?, :persisted?, :id, to: :resource

  validates :account_id,
            presence: true,
            unless: -> { account.present? }

  validates :sender_id, alphanumeric_sender_id_format: true
  validate :validate_sender_id_uniqueness

  def self.model_name
    ActiveModel::Name.new(self, nil, "AlphanumericSenderID")
  end

  def save
    return false if invalid?

    self.resource = CreateAlphanumericSenderID.call(
      {
        sender_id:,
        account: scoped_account
      },
      notify: true
    )
  end

  def account_options_for_select
    accounts_scope.pluck(:name, :id)
  end

  private

  def accounts_scope
    carrier.accounts.carrier_managed
  end

  def scoped_account
    account.present? ? account : accounts_scope.find(account_id)
  end

  def validate_sender_id_uniqueness
    return if errors.any?

    if carrier.alphanumeric_sender_ids.approved.exists?(sender_id:) || scoped_account.alphanumeric_sender_ids.exists?(sender_id:)
      errors.add(:sender_id, :taken)
    end
  end
end
