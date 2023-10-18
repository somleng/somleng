class AccountSettingsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name
  attribute :account
  attribute :tts_configuration_attributes, default: {}
  attribute :tts_configuration, default: -> { TTSConfigurationForm.new }
  delegate :persisted?, :id, to: :account

  validates :name, presence: true
  validates :tts_configuration, nested_form: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "AccountSettings")
  end

  def self.initialize_with(account)
    new(
      account:,
      name: account.name,
      tts_configuration: TTSConfigurationForm.initialize_with(account.tts_configuration)
    )
  end

  def tts_configuration_attributes=(attributes)
    super
    tts_configuration.assign_attributes(attributes)
  end

  def account=(account)
    super
    tts_configuration.account = account
  end

  def save
    return false if invalid?

    account.name = name

    Account.transaction do
      account.save!
      tts_configuration.save
    end
  end
end
