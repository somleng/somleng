class DefaultTTSConfigurationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend Enumerize

  attribute :default_tts_configuration, default: -> { DefaultTTSConfiguration.new }
  attribute :voice, default: -> { DefaultTTSConfiguration.new.voice_identifier }
  delegate :persisted?, :id, to: :default_tts_configuration

  enumerize :voice, in: DefaultTTSConfiguration.voice_identifier.values

  validates :voice, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "DefaultTTSConfiguration")
  end

  def self.initialize_with(default_tts_configuration)
    new(
      default_tts_configuration:,
      voice: default_tts_configuration.voice_identifier
    )
  end

  def save
    return false if invalid?

    default_tts_configuration.voice_identifier = voice
    default_tts_configuration.save!
  end

  def voice_options_for_select
    TTSVoices::Voice.all.map do |voice|
      [voice.to_s, voice.identifier]
    end
  end
end
