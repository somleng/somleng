class AccountMembershipForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  enumerize :role, in: AccountMembership.role.values

  attribute :current_account
  attribute :current_carrier
  attribute :account_id
  attribute :name
  attribute :email
  attribute :role
  attribute :account_membership, default: -> { AccountMembership.new(role: :owner) }

  validates :name, presence: true, unless: :persisted?
  validates :email, format: User::EMAIL_FORMAT, allow_nil: true, allow_blank: true
  validates :email, presence: true, unless: :persisted?
  validates :role, presence: true, if: :account_managed?
  validates :account_id, presence: true, if: :require_account_id?
  validate  :validate_email

  delegate :user, :persisted?, :new_record?, :id, to: :account_membership

  def self.model_name
    ActiveModel::Name.new(self, nil, "AccountMembership")
  end

  def self.initialize_with(account_membership)
    new(
      account_membership: account_membership,
      current_account: account_membership.account,
      name: account_membership.user.name,
      email: account_membership.user.email,
      role: account_membership.role
    )
  end

  def save
    return false if invalid?

    AccountMembership.transaction do
      account_membership.user ||= invite_user!
      account_membership.account ||= account
      account_membership.role = role if role.present?
      account_membership.save!
    end
  end

  def account_options_for_select
    current_carrier.accounts.map do |account|
      {
        id: account.id,
        text: account.name
      }
    end
  end

  def require_account_id?
    current_account.blank?
  end

  private

  def validate_email
    return if email.blank?

    if carrier_managed?
      errors.add(:email, :taken) if current_carrier.users.exists?(email: email)
    elsif account.users.exists?(email: email)
      errors.add(:email, :taken)
    end
  end

  def account
    current_account || current_carrier.accounts.find_by(id: account_id)
  end

  def invite_user!
    User.invite!(name: name, email: email)
  end

  def account_managed?
    current_account.present?
  end

  def carrier_managed?
    current_carrier.present?
  end
end
