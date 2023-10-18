require "rails_helper"

RSpec.describe AccountSettingsForm do
  describe "validations" do
    it "validates name" do
      form = AccountSettingsForm.new(
        name: nil
      )

      expect(form).to be_invalid
      expect(form.errors[:name]).to be_present
    end

    it "validates default_tts_configuration" do
      form = AccountSettingsForm.new(
        default_tts_configuration: DefaultTTSConfigurationForm.new(
          voice: nil
        )
      )

      expect(form).to be_invalid
      expect(form.errors[:"default_tts_configuration.voice"]).to be_present
    end
  end
end
