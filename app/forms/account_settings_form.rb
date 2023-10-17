class AccountSettingsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name
  attribute :account
  delegate :persisted?, :id, to: :account

  validates :name, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "AccountSettings")
  end

  def self.initialize_with(account)
    new(
      account:,
      name: account.name
    )
  end

  def default_tts_configuration
    DefaultTTSConfigurationForm.initialize_with(account.default_tts_configuration)
  end

  def save
    return false if invalid?

    account.attributes = {
      name:
    }

    account.save!
  end
end
