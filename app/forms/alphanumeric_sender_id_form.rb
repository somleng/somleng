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

  def self.initialize_with(resource)
    new(
      resource:,
      carrier: resource.carrier,
      account: resource.account,
      sender_id: resource.sender_id
    )
  end

  def save
    return false if invalid?

    resource.attributes = {
      carrier:,
      sender_id:
    }

    if carrier_managed?
      resource.account = accounts_scope.find(account_id)
      resource.approval_status = :approved
    else
      resource.account = account
    end

    resource.save!
  end

  def account_options_for_select
    accounts_scope.pluck(:name, :id)
  end

  private

  def carrier_managed?
    account.blank?
  end

  def accounts_scope
    carrier.accounts.carrier_managed
  end

  def validate_sender_id_uniqueness
    errors.add(:sender_id, :taken) if carrier.alphanumeric_sender_ids.approved.exists?(sender_id:)
  end
end
