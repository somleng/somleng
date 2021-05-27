class AccountForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :name
  attribute :enabled, :boolean, default: true
  attribute :account, default: -> { Account.new(access_token: Doorkeeper::AccessToken.new) }

  delegate :persisted?, :id, to: :account

  validates :name, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "Account")
  end

  def self.initialize_with(account)
    new(
      account: account,
      name: account.name,
      enabled: account.enabled?
    )
  end

  def save
    return false if invalid?

    account.attributes = {
      carrier: carrier,
      name: name,
      status: enabled ? "enabled" : "disabled"
    }

    account.save!
  end
end
