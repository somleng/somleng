class DefaultTTSConfigurationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend Enumerize

  attribute :default_tts_configuration
  attribute :provider, default: -> { DefaultTTSConfiguration.new.provider }
  attribute :language, default: -> { DefaultTTSConfiguration.new.language }
  delegate :persisted?, :id, to: :default_tts_configuration

  enumerize :provider, in: DefaultTTSConfiguration.provider.values
  enumerize :language, in: DefaultTTSConfiguration.language.values

  validates :provider, :language, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "DefaultTTSConfiguration")
  end

  def self.initialize_with(default_tts_configuration)
    new(
      default_tts_configuration:,
      provider: default_tts_configuration.provider,
      language: default_tts_configuration.language
    )
  end

  def save
    return false if invalid?

    default_tts_configuration.attributes = {
      provider:,
      language:
    }

    default_tts_configuration.save!
  end
end
