class AccountMembershipForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  enumerize :role, in: AccountMembership.role.values

  attribute :account_id
  attribute :account
  attribute :name
  attribute :email
  attribute :role
  attribute :carrier
  attribute :account_membership, default: -> { AccountMembership.new }

  validates :name, :email, presence: true, unless: :persisted?
  validates :role, presence: true
  validates :account_id, presence: true, unless: ->(f) { f.account.present? || f.persisted? }

  delegate :user, :persisted?, :id, to: :account_membership

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
      account_membership.account ||= accounts_scope.find(account_id)
      account_membership.role = role
      account_membership.save!
    end
  end

  def account_options_for_select
    accounts_scope.map do |account|
      {
        id: account.id,
        text: account.name
      }
    end
  end

  private

  def accounts_scope
    carrier.accounts
  end

  def invite_user!
    User.invite!(name: name, email: email)
  end
end
