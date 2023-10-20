class AccountSettingsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name
  attribute :account
  attribute :default_tts_voice, TTSVoiceType.new

  delegate :persisted?, :id, to: :account

  validates :name, :default_tts_voice, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "AccountSettings")
  end

  def self.initialize_with(account)
    new(
      account:,
      name: account.name,
      default_tts_voice: account.default_tts_voice
    )
  end

  def save
    return false if invalid?

    account.name = name
    account.default_tts_voice = default_tts_voice

    account.save!
  end
end
