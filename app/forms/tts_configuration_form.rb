class TTSConfigurationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend Enumerize

  attribute :account
  attribute :tts_configuration, default: -> { TTSConfiguration.new }
  attribute :voice, default: -> { TTSConfiguration.new.voice_identifier }
  delegate :persisted?, :id, to: :tts_configuration

  enumerize :voice, in: TTSConfiguration.voice_identifier.values

  validates :voice, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "TTSConfiguration")
  end

  def self.initialize_with(tts_configuration)
    new(
      tts_configuration:,
      voice: tts_configuration.voice_identifier
    )
  end

  def save
    return false if invalid?

    tts_configuration = account.tts_configuration || account.build_tts_configuration
    tts_configuration.voice_identifier = voice
    tts_configuration.save!
  end

  def voice_options_for_select
    TTSVoices::Voice.all.map do |voice|
      [voice.to_s, voice.identifier]
    end
  end
end
