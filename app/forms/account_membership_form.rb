class AccountMembershipForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  enumerize :role, in: AccountMembership.role.values

  attribute :account
  attribute :name
  attribute :email
  attribute :role, default: :admin
  attribute :current_user
  attribute :account_membership, default: -> { AccountMembership.new }

  validates :name, presence: true, unless: :persisted?
  validates :email, format: User::EMAIL_FORMAT, allow_nil: true, allow_blank: true
  validates :email, presence: true, unless: :persisted?
  validates :role, presence: true
  validate  :validate_email

  delegate :user, :persisted?, :new_record?, :id, to: :account_membership

  def self.model_name
    ActiveModel::Name.new(self, nil, "AccountMembership")
  end

  def self.initialize_with(account_membership)
    new(
      account_membership: account_membership,
      account: account_membership.account,
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
      account_membership.role = role
      account_membership.save!
    end
  end

  private

  def validate_email
    return if errors[:email].any?

    errors.add(:email, :taken) if account.users.exists?(email: email) || User.carrier.exists?(email: email)
  end

  def invite_user!
    User.invite!({ name: name, email: email }, current_user)
  end
end
