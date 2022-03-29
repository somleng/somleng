class AccountForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :name
  attribute :enabled, :boolean, default: true
  attribute :account, default: -> { Account.new(access_token: Doorkeeper::AccessToken.new) }
  attribute :outbound_sip_trunk_id
  attribute :owner_name
  attribute :owner_email
  attribute :current_user

  delegate :persisted?, :id, :customer_managed?, to: :account

  validates :name, presence: true, unless: :persisted?
  validates :owner_email, format: User::EMAIL_FORMAT, allow_blank: true, allow_nil: true
  validate :validate_owner

  def self.model_name
    ActiveModel::Name.new(self, nil, "Account")
  end

  def self.initialize_with(account)
    new(
      account:,
      carrier: account.carrier,
      name: account.name,
      outbound_sip_trunk_id: account.outbound_sip_trunk_id,
      enabled: account.enabled?,
      owner_name: account.owner&.name,
      owner_email: account.owner&.email
    )
  end

  def save
    return false if invalid?

    account.carrier = carrier
    account.status = enabled ? "enabled" : "disabled"
    account.name = name if name.present?

    if outbound_sip_trunk_id.present?
      account.outbound_sip_trunk = carrier.outbound_sip_trunks.find(outbound_sip_trunk_id)
    end

    Account.transaction do
      account.save!
      invite_owner! if owner_email.present?
      true
    end
  end

  def outbound_sip_trunk_options_for_select
    carrier.outbound_sip_trunks.map do |outbound_sip_trunk|
      {
        id: outbound_sip_trunk.id,
        text: outbound_sip_trunk.name
      }
    end
  end

  private

  def validate_owner
    return if owner_email.blank? && owner_name.blank?
    return errors.add(:owner_email, :blank) if owner_name.present? && owner_email.blank?
    return errors.add(:owner_name, :blank) if owner_email.present? && owner_name.blank?
    return errors.add(:owners_email, :invalid) if customer_managed?
    return errors.add(:owner_email, :taken) if User.carrier.exists?(email: owner_email)
  end

  def validate_name
    errors.add(:name, :invalid) if name.present? && customer_managed?
  end

  def invite_owner!
    AccountMembership.create!(
      account:,
      user: User.invite!({ email: owner_email, name: owner_name }, current_user),
      role: :owner
    )
  end
end
