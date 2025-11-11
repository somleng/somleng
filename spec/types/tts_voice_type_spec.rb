require "rails_helper"

RSpec.describe TTSVoiceType do
  it "handles TTS Voices" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :tts_voice, TTSVoiceType.new
    end

    expect(klass.new(tts_voice: "Basic.Kal").tts_voice).to have_attributes(
      identifier: "Basic.Kal"
    )
    expect(klass.new(tts_voice: nil).tts_voice).to be_nil
    expect(klass.new(tts_voice: "Invalid.Voice").tts_voice).to be_nil
  end
end
