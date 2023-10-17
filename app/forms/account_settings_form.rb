class AccountSettingsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name
  attribute :account
  attribute :default_tts_configuration_attributes, default: {}
  attribute :default_tts_configuration
  delegate :persisted?, :id, to: :account

  validates :name, presence: true
  validates :default_tts_configuration, nested_form: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "AccountSettings")
  end

  def self.initialize_with(account)
    new(
      account:,
      name: account.name,
      default_tts_configuration: DefaultTTSConfigurationForm.initialize_with(account.default_tts_configuration)
    )
  end

  def save
    self.default_tts_configuration ||= DefaultTTSConfigurationForm.new(
      default_tts_configuration: account.default_tts_configuration,
      **default_tts_configuration_attributes
    )

    return false if invalid?

    account.attributes = {
      name:
    }

    ApplicationRecord.transaction do
      account.save!
      default_tts_configuration.save
    end
  end
end
