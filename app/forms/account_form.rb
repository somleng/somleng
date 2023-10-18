class AccountForm
  extend Enumerize
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :name
  attribute :enabled, :boolean, default: true
  attribute :account, default: -> { Account.new(access_token: Doorkeeper::AccessToken.new) }
  attribute :sip_trunk_id
  attribute :owner_name
  attribute :owner_email
  attribute :current_user
  attribute :calls_per_second, :integer, default: 1
  attribute :default_tts_configuration_attributes, default: {}
  attribute :default_tts_configuration, default: -> { DefaultTTSConfigurationForm.new }

  delegate :persisted?, :id, :customer_managed?, to: :account

  validates :name, presence: true, unless: :persisted?
  validates :owner_email, email_format: true, allow_blank: true, allow_nil: true
  validates :calls_per_second,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 100,
              only_integer: true
            }

  validates :default_tts_configuration, nested_form: true
  validate :validate_owner

  def self.model_name
    ActiveModel::Name.new(self, nil, "Account")
  end

  def self.initialize_with(account)
    new(
      account:,
      carrier: account.carrier,
      name: account.name,
      sip_trunk_id: account.sip_trunk_id,
      enabled: account.enabled?,
      calls_per_second: account.calls_per_second,
      owner_name: account.owner&.name,
      owner_email: account.owner&.email,
      default_tts_configuration: DefaultTTSConfigurationForm.initialize_with(account.default_tts_configuration)
    )
  end

  def save
    self.default_tts_configuration = DefaultTTSConfigurationForm.new(
      **default_tts_configuration_attributes
    )

    return false if invalid?

    account.carrier = carrier
    account.status = enabled ? "enabled" : "disabled"
    account.name = name if name.present?
    account.calls_per_second = calls_per_second

    account.sip_trunk = carrier.sip_trunks.find(sip_trunk_id) if sip_trunk_id.present?

    Account.transaction do
      account.save!
      default_tts_configuration.default_tts_configuration = account.build_default_tts_configuration
      default_tts_configuration.save
      invite_owner! if owner_email.present?
      true
    end
  end

  def sip_trunk_options_for_select
    sip_trunks = carrier.sip_trunks.select(&:configured_for_outbound_dialing?)
    sip_trunks.map { |item| [item.name, item.id] }
  end

  private

  def validate_owner
    return if owner_email.blank? && owner_name.blank?
    return errors.add(:owner_email, :blank) if owner_name.present? && owner_email.blank?
    return errors.add(:owner_name, :blank) if owner_email.present? && owner_name.blank?
    return errors.add(:owners_email, :invalid) if customer_managed?

    errors.add(:owner_email, :taken) if User.exists?(carrier:, email: owner_email)
  end

  def validate_name
    errors.add(:name, :invalid) if name.present? && customer_managed?
  end

  def invite_owner!
    AccountMembership.create!(
      account:,
      user: User.invite!({ carrier:, email: owner_email, name: owner_name }, current_user),
      role: :owner
    )
  end
end
