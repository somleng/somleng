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

    it "validates tts_configuration" do
      form = AccountSettingsForm.new(
        tts_configuration_attributes: { voice: nil }
      )

      expect(form).to be_invalid
      expect(form.errors[:"tts_configuration.voice"]).to be_present
    end
  end

  describe "#save" do
    it "saves the account settings" do
      account = create(:account)

      form = AccountSettingsForm.new(
        account:,
        name: "Rocket Rides",
        tts_configuration_attributes: { voice: "Basic.Kal" }
      )

      result = form.save

      expect(result).to eq(true)
      expect(form.account).to have_attributes(
        name: "Rocket Rides",
        tts_configuration: have_attributes(
          voice_identifier: "Basic.Kal"
        )
      )
    end
  end
end
